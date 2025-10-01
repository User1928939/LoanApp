# app/schemas.py
from datetime import date, datetime
from decimal import Decimal
from typing import Optional, Literal

from pydantic import BaseModel, Field, EmailStr

from models import Currency, LoanStatus, EventType

# ===== Users =====
class UserCreate(BaseModel):
    phone: str = Field(min_length=6, max_length=32)
    email: EmailStr
    pseudonym: Optional[str] = None
    photo_url: Optional[str] = None

class UserOut(BaseModel):
    id: int
    phone: str
    email: EmailStr
    pseudonym: Optional[str]
    photo_url: Optional[str]
    class Config:
        from_attributes = True

# ===== Loans =====
class LoanCreate(BaseModel):
    lender_id: int
    borrower_id: int
    amount: Decimal = Field(gt=0)
    currency: Currency = Currency.MAD
    due_date: date
    created_by_id: int = Field(description="ID of the user creating the loan (either lender or borrower)")

class LoanOut(BaseModel):
    id: int
    lender_id: int
    borrower_id: int
    amount: Decimal
    currency: Currency
    due_date: date
    status: LoanStatus
    lender_confirmed: bool
    borrower_confirmed: bool
    confirmed_at: Optional[datetime]
    created_by_id: int
    created_at: datetime
    class Config:
        from_attributes = True

# ===== Confirmations =====
class ConfirmationCreate(BaseModel):
    type: EventType
    # For REPAYMENT: payload = {"amount": Decimal}
    # For DUE_DATE_CHANGE: payload = {"new_due_date": "YYYY-MM-DD"}
    payload: dict
    requested_by_id: int

class ConfirmationOut(BaseModel):
    id: int
    loan_id: int
    type: EventType
    payload: dict
    lender_accepted: bool
    borrower_accepted: bool
    finalized_at: Optional[datetime]
    created_at: datetime
    class Config:
        from_attributes = True

class ConfirmationAction(BaseModel):
    accept: bool  # True to accept, False to reject/cancel
    actor_role: Literal["LENDER", "BORROWER"]
