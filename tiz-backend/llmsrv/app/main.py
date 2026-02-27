"""FastAPI main application for Tiz AI Service."""

import json
import logging
import uuid
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse

from app.config import get_settings
from app.graphs import build_chat_graph, build_generate_graph, build_grade_graph
from app.models import (
    ChatEventType,
    ChatRequest,
    ChatSessionEvent,
    ChatMessageEvent,
    ChatConfirmEvent,
    ChatDoneEvent,
    ChatErrorEvent,
    GenerateRequest,
    GenerateResponse,
    GradeRequest,
    GradeResponse,
)
from app.nodes.analyze import ChatState

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    logger.info("Starting Tiz AI Service...")
    yield
    logger.info("Shutting down Tiz AI Service...")


app = FastAPI(
    title="Tiz AI Service",
    description="LangGraph-based AI backend for question generation and grading",
    version="0.1.0",
    lifespan=lifespan,
)


def _format_sse_event(event_type: str, data: dict) -> str:
    """Format data as SSE event.

    Args:
        event_type: SSE event type
        data: Event data dictionary

    Returns:
        Formatted SSE string
    """
    return f"event: {event_type}\ndata: {json.dumps(data, ensure_ascii=False)}\n\n"


@app.get("/health")
async def health_check() -> dict:
    """Health check endpoint."""
    return {"status": "healthy", "service": "llmsrv"}


@app.post("/internal/ai/chat")
async def chat(request: ChatRequest) -> StreamingResponse:
    """Chat endpoint with SSE streaming.

    Streams events as:
    - session: Session ID for the conversation
    - message: Message content chunks
    - confirm: Confirmation request for question generation
    - done: Conversation complete
    - error: Error occurred
    """
    async def generate() -> AsyncGenerator[str, None]:
        session_id = request.session_id or str(uuid.uuid4())

        try:
            # Send session event
            session_event = ChatSessionEvent(session_id=session_id)
            yield _format_sse_event(
                ChatEventType.SESSION.value,
                session_event.model_dump(),
            )

            # Build and run chat graph
            graph = build_chat_graph()

            initial_state: ChatState = {
                "session_id": session_id,
                "message": request.message,
                "history": request.history,
                "response": "",
                "intent": "chat",
                "topic": None,
                "count": None,
                "difficulty": None,
                "question_types": None,
                "summary": None,
                "questions": None,
                "error": None,
            }

            # Stream graph execution
            async for event in graph.astream(initial_state):
                for node_name, node_state in event.items():
                    logger.debug(f"Node {node_name} completed")

                    # Handle different nodes
                    if node_name == "generate_content":
                        response = node_state.get("response", "")
                        if response:
                            # Send message event
                            message_event = ChatMessageEvent(content=response)
                            yield _format_sse_event(
                                ChatEventType.MESSAGE.value,
                                message_event.model_dump(),
                            )

                        # Check for confirmation
                        summary = node_state.get("summary")
                        if summary:
                            confirm_event = ChatConfirmEvent(summary=summary)
                            yield _format_sse_event(
                                ChatEventType.CONFIRM.value,
                                confirm_event.model_dump(),
                            )

                    elif node_name == "generate_questions":
                        questions = node_state.get("questions", [])
                        summary = node_state.get("summary", {})
                        if questions:
                            # Send generated questions as message
                            questions_data = {
                                "questions": [q.model_dump() for q in questions],
                                "summary": summary,
                            }
                            message_event = ChatMessageEvent(
                                content=json.dumps(questions_data, ensure_ascii=False)
                            )
                            yield _format_sse_event(
                                ChatEventType.MESSAGE.value,
                                message_event.model_dump(),
                            )

            # Send done event
            done_event = ChatDoneEvent()
            yield _format_sse_event(
                ChatEventType.DONE.value,
                done_event.model_dump(),
            )

        except Exception as e:
            logger.error(f"Error in chat: {e}")
            error_event = ChatErrorEvent(
                type="api_error",
                code="ai_service_error",
                message=str(e),
            )
            yield _format_sse_event(
                ChatEventType.ERROR.value,
                error_event.model_dump(),
            )

    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@app.post("/internal/ai/generate", response_model=GenerateResponse)
async def generate_questions(request: GenerateRequest) -> GenerateResponse:
    """Generate questions directly without chat.

    Args:
        request: Generation parameters

    Returns:
        Generated questions
    """
    try:
        graph = build_generate_graph()

        initial_state = {
            "topic": request.topic,
            "count": request.count,
            "difficulty": request.difficulty,
            "question_types": [qt.value for qt in request.question_types],
            "questions": None,
            "summary": None,
            "error": None,
        }

        final_state = await graph.ainvoke(initial_state)

        if final_state.get("error"):
            raise HTTPException(
                status_code=500,
                detail=final_state["error"],
            )

        questions = final_state.get("questions", [])
        summary = final_state.get("summary", {})

        return GenerateResponse(questions=questions, summary=summary)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating questions: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate questions: {e}",
        )


@app.post("/internal/ai/grade", response_model=GradeResponse)
async def grade_answer(request: GradeRequest) -> GradeResponse:
    """Grade an essay answer.

    Args:
        request: Grading parameters

    Returns:
        Grading result with score and feedback
    """
    try:
        graph = build_grade_graph()

        initial_state = {
            "question_content": request.question_content,
            "question_answer": request.question_answer,
            "user_answer": request.user_answer,
            "rubric": request.rubric,
            "result": None,
            "error": None,
        }

        final_state = await graph.ainvoke(initial_state)

        if final_state.get("error"):
            logger.warning(f"Grading completed with error: {final_state['error']}")

        result = final_state.get("result")
        if result is None:
            raise HTTPException(
                status_code=500,
                detail="Failed to grade answer",
            )

        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error grading answer: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to grade answer: {e}",
        )


if __name__ == "__main__":
    import uvicorn

    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=settings.service_port,
        reload=settings.debug,
    )
