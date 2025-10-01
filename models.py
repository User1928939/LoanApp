# Table to store user friendships
# app/models.py
from datetime import datetime, date
from decimal import Decimal
from typing import Optional

from sqlalchemy import (
    String, Integer, DateTime, Date, Enum, ForeignKey, Boolean,
    Numeric, JSON, UniqueConstraint, Index
)
from sqlalchemy.orm import relationship, Mapped, mapped_column
import enum

from db import Base

# === Enums aligned with CDC HedNiya ===
class LoanStatus(str, enum.Enum):
    PENDING = "PENDING"               # awaiting both confirmations
    ACTIVE = "ACTIVE"                 # confirmed loan, due date in future
    CLOSED = "CLOSED"                 # fully repaid (history)
    OVERDUE = "OVERDUE"               # passed due_date and still active
    CANCELLED = "CANCELLED"           # explicitly cancelled before activation

class EventType(str, enum.Enum):
    LOAN_CREATE = "LOAN_CREATE"
    REPAYMENT = "REPAYMENT"
    DUE_DATE_CHANGE = "DUE_DATE_CHANGE"

class Currency(str, enum.Enum):
    MAD = "MAD"   # default
    USD = "USD"
    EUR = "EUR"

# === Core tables ===
class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    phone: Mapped[Optional[str]] = mapped_column(String(32), unique=True, index=True)   # encrypted at rest in prod
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)  # Gmail required by CDC
    pseudonym: Mapped[Optional[str]] = mapped_column(String(64))
    photo_url: Mapped[Optional[str]] = mapped_column(String(512))
    is_2fa_enabled: Mapped[Optional[bool]] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # relationships
    loans_lent: Mapped[list["Loan"]] = relationship(foreign_keys="Loan.lender_id", back_populates="lender")
    loans_borrowed: Mapped[list["Loan"]] = relationship(foreign_keys="Loan.borrower_id", back_populates="borrower")

class UserFriend(Base):
    __tablename__ = "user_friends"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    friend_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Optionally, add a relationship for easier access
    user: Mapped["User"] = relationship(foreign_keys=[user_id])
    friend: Mapped["User"] = relationship(foreign_keys=[friend_id])

class Loan(Base):
    __tablename__ = "loans"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    lender_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    borrower_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)

    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    currency: Mapped[Currency] = mapped_column(Enum(Currency), default=Currency.MAD)

    due_date: Mapped[date] = mapped_column(Date)
    status: Mapped[LoanStatus] = mapped_column(Enum(LoanStatus), default=LoanStatus.PENDING)

    # Double confirmation for creation
    lender_confirmed: Mapped[bool] = mapped_column(Boolean, default=False)
    borrower_confirmed: Mapped[bool] = mapped_column(Boolean, default=True)
    confirmed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)

    created_by_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    lender: Mapped[User] = relationship(foreign_keys=[lender_id], back_populates="loans_lent")
    borrower: Mapped[User] = relationship(foreign_keys=[borrower_id], back_populates="loans_borrowed")

    events: Mapped[list["Confirmation"]] = relationship(back_populates="loan", cascade="all, delete-orphan")

    __table_args__ = (
        Index("ix_loans_status_due_date", "status", "due_date"),
    )

class Confirmation(Base):
    """
    Tracks any action requiring *both* parties' agreement:
      - LOAN_CREATE (initial confirmation)
      - REPAYMENT (a repayment record proposal)
      - DUE_DATE_CHANGE (proposed new due date)
    `payload` stores action-specific fields (e.g., {'amount': 200.00} or {'new_due_date': '2025-12-31'})
    """
    __tablename__ = "confirmations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    loan_id: Mapped[int] = mapped_column(ForeignKey("loans.id", ondelete="CASCADE"), index=True)
    type: Mapped[EventType] = mapped_column(Enum(EventType))
    payload: Mapped[dict] = mapped_column(JSON, default=dict)

    requested_by_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))

    lender_accepted: Mapped[bool] = mapped_column(Boolean, default=False)
    borrower_accepted: Mapped[bool] = mapped_column(Boolean, default=True)
    finalized_at: Mapped[Optional[datetime]] = mapped_column(DateTime)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    loan: Mapped[Loan] = relationship(back_populates="events")

class HederaLog(Base):
    """
    Soft non-repudiation: we log a tiny HBAR transfer between two admin accounts (A→B or B→A)
    with meta for audit (per CDC; no user wallets exposed).
    """
    __tablename__ = "hedera_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    loan_id: Mapped[int] = mapped_column(ForeignKey("loans.id", ondelete="CASCADE"), index=True)
    event_id: Mapped[int] = mapped_column(ForeignKey("confirmations.id", ondelete="SET NULL"))

    direction: Mapped[str] = mapped_column(String(3))  # 'A2B' or 'B2A'
    tx_id: Mapped[Optional[str]] = mapped_column(String(128))  # explorer reference
    meta: Mapped[dict] = mapped_column(JSON, default=dict)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class Notification(Base):
    """
    Scheduled reminders (push/SMS/email) per CDC:
      - 3 days before due_date: daily push
      - day D: SMS + email
      - 2 days after due_date: every 5 days
      - immediate alerts for due-date changes
    """
    __tablename__ = "notifications"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    loan_id: Mapped[int] = mapped_column(ForeignKey("loans.id", ondelete="CASCADE"), index=True)
    type: Mapped[str] = mapped_column(String(32))         # e.g., 'DUE_SOON', 'D_DAY', 'PAST_DUE', 'DATE_CHANGED'
    scheduled_at: Mapped[datetime] = mapped_column(DateTime, index=True)
    sent_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)

    payload: Mapped[dict] = mapped_column(JSON, default=dict)
