# app/routers/loans.py
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from decimal import Decimal

from db import get_session
import models, schemas

router = APIRouter(prefix="/loans", tags=["loans"])
from fastapi import Body

@router.post("/{loan_id}/confirm", response_model=schemas.LoanOut)
async def confirm_loan(loan_id: int, body: dict = Body(...), db: AsyncSession = Depends(get_session)):
    """
    Endpoint to confirm a loan for either lender or borrower.
    Expects: {"user_id": int, "confirmed": bool}
    """
    loan = await db.get(models.Loan, loan_id)
    if not loan:
        raise HTTPException(404, "Loan not found")
    user_id = body.get("user_id")
    confirmed = body.get("confirmed", True)
    if user_id is None:
        raise HTTPException(400, "Missing user_id")
    # Mark confirmation for lender or borrower
    if user_id == loan.lender_id:
        loan.lender_confirmed = confirmed
    elif user_id == loan.borrower_id:
        loan.borrower_confirmed = confirmed
    else:
        raise HTTPException(403, "User is not lender or borrower")
    # If both confirmed, set confirmed_at and status
    if loan.lender_confirmed and loan.borrower_confirmed:
        loan.confirmed_at = datetime.utcnow()
        loan.status = models.LoanStatus.ACTIVE
    await db.commit()
    await db.refresh(loan)
    return loan

# --- helpers ---
async def _recompute_status(loan: models.Loan) -> None:
    if loan.status in (models.LoanStatus.CANCELLED, models.LoanStatus.CLOSED):
        return
    today = datetime.utcnow().date()
    if loan.confirmed_at:
        loan.status = models.LoanStatus.OVERDUE if loan.due_date < today else models.LoanStatus.ACTIVE
    else:
        loan.status = models.LoanStatus.PENDING

@router.post("", response_model=schemas.LoanOut, status_code=201)
async def create_loan(payload: schemas.LoanCreate, db: AsyncSession = Depends(get_session)):
    if payload.lender_id == payload.borrower_id:
        raise HTTPException(400, "Lender and borrower must be different")

    # Determine who created the loan (borrower or lender)
    is_borrower_creating = payload.created_by_id == payload.borrower_id
    
    loan = models.Loan(
        lender_id=payload.lender_id,
        borrower_id=payload.borrower_id,
        amount=payload.amount,
        currency=payload.currency,
        due_date=payload.due_date,
        status=models.LoanStatus.PENDING,
        created_by_id=payload.created_by_id,
        # Set initial confirmation based on who created the loan
        lender_confirmed=False,  # Lender always needs to confirm
        borrower_confirmed=is_borrower_creating  # Auto-confirm if borrower creates it
    )
    db.add(loan)
    await db.commit()
    await db.refresh(loan)
    return loan

# TODO: These endpoints will be implemented later for advanced features
# @router.post("/{loan_id}/confirmations")
# async def propose_action(loan_id: int, body: schemas.ConfirmationCreate, db: AsyncSession = Depends(get_session)):
#     """
#     Future endpoint for proposing changes to an active loan (due date changes, repayments)
#     """
#     pass

# @router.post("/{loan_id}/confirmations/{conf_id}/act")
# async def act_on_confirmation(
#     loan_id: int, conf_id: int, body: schemas.ConfirmationAction, db: AsyncSession = Depends(get_session)
# ):
#     """
#     Future endpoint for accepting/rejecting proposed changes to an active loan
#     """
#     pass

@router.get("/{loan_id}", response_model=schemas.LoanOut)
async def get_loan(loan_id: int, db: AsyncSession = Depends(get_session)):
    loan = await db.get(models.Loan, loan_id)
    if not loan:
        raise HTTPException(404, "Loan not found")
    await _recompute_status(loan)
    await db.commit()
    await db.refresh(loan)
    return loan

@router.get("/dashboard/{user_id}")
async def dashboard(user_id: int, db: AsyncSession = Depends(get_session)):
    """
    Returns the two blocks specified by the CDC:
     - 'Mes prêts en cours' (ACTIVE, OVERDUE) => orange
     - 'Historique clos' (CLOSED) => green
    """
    q_active = await db.execute(
        select(models.Loan).where(
            ((models.Loan.lender_id == user_id) | (models.Loan.borrower_id == user_id)) &
            (models.Loan.status.in_([models.LoanStatus.PENDING, models.LoanStatus.ACTIVE]))
        )
    )
    q_closed = await db.execute(
        select(models.Loan).where(
            ((models.Loan.lender_id == user_id) | (models.Loan.borrower_id == user_id)) &
            (models.Loan.status == models.LoanStatus.CLOSED)
        )
    )
    return {
        "in_progress": [schemas.LoanOut.model_validate(row) for row in q_active.scalars().all()],
        "closed": [schemas.LoanOut.model_validate(row) for row in q_closed.scalars().all()],
    }
