"""Analyze intent node for LangGraph workflow."""

import json
import logging
import re
from typing import TypedDict

from app.llm import get_llm_client
from app.utils import get_prompts

logger = logging.getLogger(__name__)


class ChatState(TypedDict):
    """State for chat workflow."""

    session_id: str | None
    message: str
    history: list[dict]
    response: str
    intent: str
    topic: str | None
    count: int | None
    difficulty: str | None
    question_types: list[str] | None
    summary: dict | None
    error: str | None


async def analyze_intent(state: ChatState) -> dict:
    """Analyze user intent to determine if they want to generate questions.

    Args:
        state: Current chat state with message and history

    Returns:
        Updated state with intent and extracted parameters if applicable
    """
    message = state["message"]
    history = state.get("history", [])

    logger.info(f"Analyzing intent for message: {message[:50]}...")

    # Use LLM to analyze intent
    prompts = get_prompts()
    llm = get_llm_client()

    analysis_prompt = prompts.format_intent_analysis(message, history)

    try:
        response = await llm.chat(analysis_prompt)
        logger.debug(f"Intent analysis response: {response}")

        # Parse JSON from response
        json_match = re.search(r"\{[\s\S]*\}", response)
        if json_match:
            data = json.loads(json_match.group())
            intent = data.get("intent", "chat")

            result: dict = {"intent": intent}

            if intent == "generate":
                result.update({
                    "topic": data.get("topic"),
                    "count": data.get("count", 5),
                    "difficulty": data.get("difficulty", "medium"),
                    "question_types": data.get("question_types", ["choice"]),
                })

            logger.info(f"Analyzed intent: {intent}")
            return result
        else:
            logger.warning("No JSON found in intent analysis, defaulting to chat")
            return {"intent": "chat"}

    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse intent analysis: {e}")
        return {"intent": "chat"}
    except Exception as e:
        logger.error(f"Error analyzing intent: {e}")
        return {"intent": "chat", "error": str(e)}
