"""Generate content nodes for LangGraph workflow."""

import json
import logging
import re
from typing import TypedDict

from app.llm import get_llm_client
from app.models import Question, QuestionType
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
    questions: list[Question] | None
    error: str | None


async def generate_content(state: ChatState) -> dict:
    """Generate conversational response for chat intent.

    Args:
        state: Current chat state with message and history

    Returns:
        Updated state with response content
    """
    message = state["message"]
    history = state.get("history", [])

    logger.info(f"Generating content for message: {message[:50]}...")

    prompts = get_prompts()
    llm = get_llm_client()

    system_prompt = prompts.format_chat_system()

    try:
        response = await llm.chat(message, system_prompt=system_prompt, history=history)
        logger.info(f"Generated response: {response[:100]}...")

        # Check if response contains confirmation marker
        if "[CONFIRM]" in response:
            # Extract confirmation info
            confirm_match = re.search(
                r"\[CONFIRM\](.*?)\[/CONFIRM\]",
                response,
                re.DOTALL
            )
            if confirm_match:
                confirm_text = confirm_match.group(1)
                summary = _parse_confirm_text(confirm_text)
                return {
                    "response": response,
                    "intent": "generate",
                    "summary": summary,
                }

        return {"response": response}

    except Exception as e:
        logger.error(f"Error generating content: {e}")
        return {"response": "", "error": str(e)}


async def generate_questions(state: ChatState) -> dict:
    """Generate questions based on extracted parameters.

    Args:
        state: Current chat state with topic, count, difficulty, etc.

    Returns:
        Updated state with generated questions
    """
    topic = state.get("topic", "")
    count = state.get("count", 5)
    difficulty = state.get("difficulty", "medium")
    question_types = state.get("question_types", ["choice"])

    logger.info(f"Generating {count} questions about: {topic}")

    prompts = get_prompts()
    llm = get_llm_client()

    generation_prompt = prompts.format_generate_questions(
        topic=topic,
        count=count,
        difficulty=difficulty,
        question_types=question_types,
    )

    try:
        response = await llm.chat(generation_prompt)
        logger.debug(f"Generation response: {response}")

        # Parse JSON from response
        json_match = re.search(r"\{[\s\S]*\}", response)
        if json_match:
            data = json.loads(json_match.group())
            questions_data = data.get("questions", [])

            questions = []
            for q in questions_data:
                q_type = q.get("type", "choice")
                question = Question(
                    type=QuestionType.CHOICE if q_type == "choice" else QuestionType.ESSAY,
                    content=q.get("content", ""),
                    options=q.get("options"),
                    answer=q.get("answer", ""),
                    explanation=q.get("explanation"),
                    rubric=q.get("rubric"),
                )
                questions.append(question)

            logger.info(f"Generated {len(questions)} questions")

            # Build summary
            summary = {
                "topic": topic,
                "count": len(questions),
                "difficulty": difficulty,
                "by_type": {
                    "choice": sum(1 for q in questions if q.type == QuestionType.CHOICE),
                    "essay": sum(1 for q in questions if q.type == QuestionType.ESSAY),
                },
            }

            return {"questions": questions, "summary": summary}

        return {"questions": [], "error": "Failed to parse questions from response"}

    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse generated questions: {e}")
        return {"questions": [], "error": str(e)}
    except Exception as e:
        logger.error(f"Error generating questions: {e}")
        return {"questions": [], "error": str(e)}


def _parse_confirm_text(text: str) -> dict:
    """Parse confirmation text to extract parameters.

    Args:
        text: Confirmation text from LLM response

    Returns:
        Dictionary with extracted parameters
    """
    result = {}

    # Extract topic
    topic_match = re.search(r"主题[:：]\s*(.+)", text)
    if topic_match:
        result["topic"] = topic_match.group(1).strip()

    # Extract count
    count_match = re.search(r"数量[:：]\s*(\d+)", text)
    if count_match:
        result["count"] = int(count_match.group(1))

    # Extract difficulty
    difficulty_match = re.search(r"难度[:：]\s*(.+)", text)
    if difficulty_match:
        result["difficulty"] = difficulty_match.group(1).strip()

    # Extract question types
    types_match = re.search(r"类型[:：]\s*(.+)", text)
    if types_match:
        types_str = types_match.group(1).strip()
        result["question_types"] = [t.strip() for t in types_str.split(",")]

    return result
