# app/main.py
from fastapi import FastAPI
from routers import loans
from routers import users
from db import engine, Base

app = FastAPI(title="HedNiya API", version="0.1.0")

@app.on_event("startup")
async def on_startup():
    # Simple, dev-only auto-migrate; replace with Alembic in prod.
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

app.include_router(loans.router)
app.include_router(users.router)
