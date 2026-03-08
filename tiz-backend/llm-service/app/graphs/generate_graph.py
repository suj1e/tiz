"""Generate questions workflow graph using LangGraph."""

import logging
from typing import TypedDict

from langgraph.graph import END, StateGraph

from app.models import Question
from app.nodes.generate import generate_questions

logger = logging.getLogger(__name__)


class GenerateState(TypedDict):
    """State for generate workflow."""

    topic: str
    count: int
    difficulty: str
    question_types: list[str]
    questions: list[Question] | None
    summary: dict | None
    error: str | None


def build_generate_graph() -> StateGraph:
    """Build the question generation workflow graph.

    Workflow:
    START -> generate_questions -> END

    Returns:
        Compiled StateGraph for generate workflow
    """
    workflow = StateGraph(GenerateState)

    # Add nodes
    workflow.add_node("generate_questions", _generate_wrapper)

    # Set entry point
    workflow.set_entry_point("generate_questions")

    # Add edge to end
    workflow.add_edge("generate_questions", END)

    return workflow.compile()


async def _generate_wrapper(state: GenerateState) -> dict:
    """Wrapper to adapt generate_questions for GenerateState.

    Args:
        state: Current generate state

    Returns:
        Updated state with generated questions
    """
    # Adapt to ChatState format expected by generate_questions
    chat_state = {
        "topic": state["topic"],
        "count": state["count"],
        "difficulty": state["difficulty"],
        "question_types": state["question_types"],
    }

    result = await generate_questions(chat_state)
    return result


# Type alias for the compiled graph
GenerateGraph = StateGraph


async def run_generate_workflow(
    topic: str,
    count: int = 5,
    difficulty: str = "medium",
    question_types: list[str] | None = None,
) -> GenerateState:
    """Run the generate workflow and return final state.

    Args:
        topic: Topic for question generation
        count: Number of questions to generate
        difficulty: Difficulty level (easy, medium, hard)
        question_types: Types of questions to generate

    Returns:
        Final generate state with questions
    """
    graph = build_generate_graph()

    initial_state: GenerateState = {
        "topic": topic,
        "count": count,
        "difficulty": difficulty,
        "question_types": question_types or ["choice"],
        "questions": None,
        "summary": None,
        "error": None,
    }

    final_state = await graph.ainvoke(initial_state)
    return final_state
