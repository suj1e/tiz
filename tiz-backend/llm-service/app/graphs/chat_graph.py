"""Chat workflow graph using LangGraph."""

import logging
from typing import TypedDict

from langgraph.graph import END, StateGraph

from app.nodes.analyze import ChatState
from app.nodes.analyze import analyze_intent
from app.nodes.generate import generate_content, generate_questions
from app.nodes.extract import extract_params

logger = logging.getLogger(__name__)


def _should_generate(state: ChatState) -> str:
    """Determine if we should generate questions based on intent.

    Args:
        state: Current chat state

    Returns:
        Next node name: 'generate' or 'end'
    """
    intent = state.get("intent", "chat")

    if intent == "generate":
        return "generate"
    return "end"


def build_chat_graph() -> StateGraph:
    """Build the chat workflow graph.

    Workflow:
    START -> analyze_intent -> generate_content -> (check intent)
                                                        |
                                                        | -> generate: extract_params -> generate_questions -> END
                                                        | -> end: END

    Returns:
        Compiled StateGraph for chat workflow
    """
    workflow = StateGraph(ChatState)

    # Add nodes
    workflow.add_node("analyze_intent", analyze_intent)
    workflow.add_node("generate_content", generate_content)
    workflow.add_node("extract_params", extract_params)
    workflow.add_node("generate_questions", generate_questions)

    # Set entry point
    workflow.set_entry_point("analyze_intent")

    # Add edges
    workflow.add_edge("analyze_intent", "generate_content")

    # Conditional edge based on intent
    workflow.add_conditional_edges(
        "generate_content",
        _should_generate,
        {
            "generate": "extract_params",
            "end": END,
        },
    )

    workflow.add_edge("extract_params", "generate_questions")
    workflow.add_edge("generate_questions", END)

    return workflow.compile()


# Type alias for the compiled graph
ChatGraph = StateGraph


async def run_chat_workflow(
    message: str,
    session_id: str | None = None,
    history: list[dict] | None = None,
) -> ChatState:
    """Run the chat workflow and return final state.

    Args:
        message: User message
        session_id: Optional session ID
        history: Optional chat history

    Returns:
        Final chat state
    """
    graph = build_chat_graph()

    initial_state: ChatState = {
        "session_id": session_id,
        "message": message,
        "history": history or [],
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

    final_state = await graph.ainvoke(initial_state)
    return final_state


async def stream_chat_workflow(
    message: str,
    session_id: str | None = None,
    history: list[dict] | None = None,
):
    """Stream the chat workflow events.

    Args:
        message: User message
        session_id: Optional session ID
        history: Optional chat history

    Yields:
        Dict with node name and state updates
    """
    graph = build_chat_graph()

    initial_state: ChatState = {
        "session_id": session_id,
        "message": message,
        "history": history or [],
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

    async for event in graph.astream(initial_state):
        yield event
