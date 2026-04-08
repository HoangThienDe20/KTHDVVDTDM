"""Database configuration and session management."""

import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker


def _build_default_sqlite_url() -> str:
    """Build a default SQLite URL based on environment.

    On Databricks, prefer DBFS so the DB survives cluster restarts.
    Locally, keep using metrics.db in project root.
    """
    if os.getenv("DATABRICKS_RUNTIME_VERSION"):
        dbfs_dir = "/dbfs/FileStore/ptdl-metrics"
        os.makedirs(dbfs_dir, exist_ok=True)
        return f"sqlite:///{dbfs_dir}/metrics.db"

    base_dir = os.path.dirname(os.path.abspath(__file__))
    return f"sqlite:///{os.path.join(base_dir, '..', 'metrics.db')}"


DATABASE_URL = os.getenv("DATABASE_URL", _build_default_sqlite_url())

# Create engine
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},  # SQLite specific
    echo=False  # Set to True for SQL query debugging
)

# Session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()


def get_db():
    """Dependency for getting database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """Initialize database tables"""
    Base.metadata.create_all(bind=engine)
