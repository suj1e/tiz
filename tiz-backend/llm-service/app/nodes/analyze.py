"""Analyze intent node for LangGraph workflow."""

import json
import logging
import re

from app.llm import get_llm_client
from app.state import ChatState
from app.utils import get_prompts

logger = logging.getLogger(__name__)


async def analyze_intent(state: ChatState) -> dict:
    """Analyze user intent to determine if they want to generate questions.

    Args:
        state: Current chat state with message and history

    Returns:
        Updated state with intent and extracted parameters if applicable

    Raises:
        ValueError: If ai_config is not provided in state
    """
    message = state["message"]
    history = state.get("history", [])
    ai_config = state.get("ai_config")

    if not ai_config:
        raise ValueError("ai_config is required in state")

    logger.info(f"Analyzing intent for message: {message[:50]}...")

    # Use LLM to analyze intent with user's AI configuration
    llm = get_llm_client()
    prompts = get_prompts()

    analysis_prompt = prompts.format_intent_analysis(message, history)

    try:
        response = await llm.chat(
            analysis_prompt,
            system_prompt=ai_config.system_prompt,
            api_key=ai_config.custom_api_key,
            api_url=ai_config.custom_api_url,
            model=ai_config.preferred_model,
            temperature=ai_config.temperature,
            max_tokens=ai_config.max_tokens,
        )
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
