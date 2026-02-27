"""Extract parameters node for LangGraph workflow."""

import logging
from typing import TypedDict

from app.nodes.analyze import ChatState

logger = logging.getLogger(__name__)


async def extract_params(state: ChatState) -> dict:
    """Extract and normalize parameters for question generation.

    This node is called when the intent is 'generate' but parameters
    may need to be extracted or normalized from the conversation.

    Args:
        state: Current chat state with intent and potentially partial params

    Returns:
        Updated state with normalized parameters
    """
    logger.info("Extracting parameters for question generation")

    # Get existing parameters or set defaults
    topic = state.get("topic")
    count = state.get("count", 5)
    difficulty = state.get("difficulty", "medium")
    question_types = state.get("question_types", ["choice"])

    # Normalize difficulty
    difficulty = _normalize_difficulty(difficulty)

    # Normalize question types
    question_types = _normalize_question_types(question_types)

    # If no topic from analysis, try to extract from message
    if not topic:
        topic = _extract_topic_from_message(state.get("message", ""))

    logger.info(
        f"Extracted params - topic: {topic}, count: {count}, "
        f"difficulty: {difficulty}, types: {question_types}"
    )

    return {
        "topic": topic,
        "count": count,
        "difficulty": difficulty,
        "question_types": question_types,
    }


def _normalize_difficulty(difficulty: str) -> str:
    """Normalize difficulty level to standard values.

    Args:
        difficulty: Input difficulty string

    Returns:
        Normalized difficulty: easy, medium, or hard
    """
    difficulty_lower = difficulty.lower()

    if difficulty_lower in ["简单", "easy", "低", "简单"]:
        return "easy"
    elif difficulty_lower in ["困难", "hard", "高", "难", "困难"]:
        return "hard"
    else:
        return "medium"


def _normalize_question_types(types: list[str]) -> list[str]:
    """Normalize question types to standard values.

    Args:
        types: List of input type strings

    Returns:
        List of normalized types: choice, essay
    """
    normalized = []
    for t in types:
        t_lower = t.lower()
        if t_lower in ["选择题", "choice", "单选", "多选"]:
            normalized.append("choice")
        elif t_lower in ["简答题", "essay", "主观题", "问答"]:
            normalized.append("essay")

    # Default to choice if no valid types
    return normalized if normalized else ["choice"]


def _extract_topic_from_message(message: str) -> str:
    """Extract topic from user message as fallback.

    Args:
        message: User's message text

    Returns:
        Extracted or default topic
    """
    # Simple heuristic: look for common patterns
    # This is a fallback - ideally topic is extracted by LLM

    import re

    # Look for "关于X" or "X相关" patterns
    about_match = re.search(r"关于(.+?)(?:的|生成|出)", message)
    if about_match:
        return about_match.group(1).strip()

    # Look for "X题目" pattern
    topic_match = re.search(r"(.+?)题目", message)
    if topic_match:
        return topic_match.group(1).strip()

    # Default topic
    return "综合知识"
