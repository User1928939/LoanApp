from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_
from models import User, UserFriend
from db import get_session

router = APIRouter()

class UserCreate(BaseModel):
    email: EmailStr

class FriendAttach(BaseModel):
    friend_id: int

class FriendAttachEmail(BaseModel):
    email: EmailStr

@router.get("/users/{user_id}", status_code=200)
async def get_user_profile(user_id: int, session: AsyncSession = Depends(get_session)):
    user = await session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {
        "id": user.id,
        "email": user.email,
        "phone": user.phone,
        "pseudonym": user.pseudonym,
        "photo_url": user.photo_url,
        "is_2fa_enabled": user.is_2fa_enabled,
        "created_at": user.created_at,
    }

@router.post("/users", status_code=201)
async def create_or_login_user(user: UserCreate, session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(User).where(User.email == user.email))
    existing_user = result.scalar_one_or_none()
    if existing_user:
        return {"id": existing_user.id, "email": existing_user.email}
    new_user = User(email=user.email)
    session.add(new_user)
    await session.commit()
    await session.refresh(new_user)
    return {"id": new_user.id, "email": new_user.email}

@router.post("/users/{user_id}/friends", status_code=201)
async def add_friend(user_id: int, body: FriendAttach, session: AsyncSession = Depends(get_session)):
    user = await session.get(User, user_id)
    friend = await session.get(User, body.friend_id)
    if not user or not friend:
        raise HTTPException(status_code=404, detail="User or friend not found")

    # Prevent duplicates (both directions)
    result = await session.execute(
        select(UserFriend).where(
            or_(
                (UserFriend.user_id == user_id) & (UserFriend.friend_id == body.friend_id),
                (UserFriend.user_id == body.friend_id) & (UserFriend.friend_id == user_id),
            )
        )
    )
    existing = result.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Already friends")

    friendship = UserFriend(user_id=user_id, friend_id=body.friend_id)
    session.add(friendship)
    await session.commit()
    await session.refresh(friendship)
    return {"friendship_id": friendship.id, "user_id": user_id, "friend_id": body.friend_id}

@router.get("/users/{user_id}/friends", status_code=200)
async def get_friends(user_id: int, session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(UserFriend).where(UserFriend.user_id == user_id))
    friendships = result.scalars().all()
    friends = []
    for f in friendships:
        friend = await session.get(User, f.friend_id)
        if friend:
            friends.append({"id": friend.id, "email": friend.email})
    return {"user_id": user_id, "friends": friends}

@router.post("/users/{user_id}/friends/email", status_code=201)
async def add_friend_by_email(user_id: int, body: FriendAttachEmail, session: AsyncSession = Depends(get_session)):
    user = await session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Find friend by email
    result = await session.execute(select(User).where(User.email == body.email))
    friend = result.scalar_one_or_none()
    if not friend:
        raise HTTPException(status_code=404, detail="Friend not found")

    # Prevent self-friendship
    if friend.id == user_id:
        raise HTTPException(status_code=400, detail="You cannot add yourself")

    # Prevent duplicates (both directions)
    result = await session.execute(
        select(UserFriend).where(
            or_(
                (UserFriend.user_id == user_id) & (UserFriend.friend_id == friend.id),
                (UserFriend.user_id == friend.id) & (UserFriend.friend_id == user_id),
            )
        )
    )
    existing = result.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Already friends")

    friendship = UserFriend(user_id=user_id, friend_id=friend.id)
    session.add(friendship)
    await session.commit()
    await session.refresh(friendship)

    return {"friendship_id": friendship.id, "user_id": user_id, "friend": {"id": friend.id, "email": friend.email}}

@router.delete("/users/{user_id}/friends/{friend_id}", status_code=200)
async def delete_friend(user_id: int, friend_id: int, session: AsyncSession = Depends(get_session)):
    """Delete a friendship between two users"""
    # First, verify both users exist
    user = await session.get(User, user_id)
    friend = await session.get(User, friend_id)
    
    if not user or not friend:
        raise HTTPException(status_code=404, detail="User not found")

    # Find the friendship record
    result = await session.execute(
        select(UserFriend).where(
            or_(
                (UserFriend.user_id == user_id) & (UserFriend.friend_id == friend_id),
                (UserFriend.user_id == friend_id) & (UserFriend.friend_id == user_id),
            )
        )
    )
    friendship = result.scalar_one_or_none()
    
    if not friendship:
        raise HTTPException(status_code=404, detail="Friendship not found")

    # Delete the friendship
    await session.delete(friendship)
    await session.commit()

    return {"message": "Friendship deleted successfully"}