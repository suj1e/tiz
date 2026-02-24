"""Tizbot main application."""

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.api.routes import router

# Configure logging
logging.basicConfig(
    level=settings.log_level,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Tizbot",
    description="AI Chat Service using LangGraph",
    version="1.0.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(router)


@app.get("/health")
async def health_check() -> dict:
    """Health check endpoint."""
    return {"status": "healthy", "service": "tizbot"}


@app.on_event("startup")
async def startup_event():
    """Application startup."""
    logger.info(f"Starting Tizbot on {settings.service_host}:{settings.service_port}")
    logger.info(f"Using LLM provider: {settings.llm_provider}")


@app.on_event("shutdown")
async def shutdown_event():
    """Application shutdown."""
    logger.info("Shutting down Tizbot")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host=settings.service_host,
        port=settings.service_port,
        reload=True,
    )
