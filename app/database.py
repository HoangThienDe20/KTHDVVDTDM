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
        candidates = [
            "/dbfs/FileStore/ptdl-metrics",
            "/local_disk0/tmp/ptdl-metrics",
            "/tmp/ptdl-metrics",
        ]
        for db_dir in candidates:
            try:
                os.makedirs(db_dir, exist_ok=True)
                return f"sqlite:///{db_dir}/metrics.db"
            except OSError:
                continue

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
