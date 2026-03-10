"""Grade answer workflow graph using LangGraph."""

import json
import logging
import re

from langgraph.graph import END, StateGraph

from app.llm import get_llm_client
from app.models import GradeResponse
from app.state import GradeState
from app.utils import get_prompts

logger = logging.getLogger(__name__)


async def grade_answer(state: GradeState) -> dict:
    """Grade user's answer using LLM.

    Args:
        state: Current grade state with question and answer

    Returns:
        Updated state with grading result

    Raises:
        ValueError: If ai_config is not provided in state
    """
    question_content = state["question_content"]
    question_answer = state["question_answer"]
    user_answer = state["user_answer"]
    ai_config = state["ai_config"]

    logger.info(f"Grading answer for question: {question_content[:50]}...")

    llm = get_llm_client()
    prompts = get_prompts()

    grading_prompt = prompts.format_grading(
        question_content=question_content,
        question_answer=question_answer,
        user_answer=user_answer,
    )

    try:
        response = await llm.chat(
            grading_prompt,
            system_prompt=ai_config.system_prompt,
            api_key=ai_config.custom_api_key,
            api_url=ai_config.custom_api_url,
            model=ai_config.preferred_model,
            temperature=ai_config.temperature,
            max_tokens=ai_config.max_tokens,
        )
        logger.debug(f"Grading response: {response}")

        # Parse JSON from response
        json_match = re.search(r"\{[\s\S]*\}", response)
        if json_match:
            data = json.loads(json_match.group())

            result = GradeResponse(
                score=float(data.get("score", 0)),
                is_correct=data.get("is_correct", False),
                feedback=data.get("feedback", ""),
                suggestions=data.get("suggestions", []),
            )

            logger.info(f"Grading complete - score: {result.score}")
            return {"result": result}

        return {
            "result": GradeResponse(
                score=0,
                is_correct=False,
                feedback="Failed to parse grading response",
                suggestions=[],
            ),
            "error": "Failed to parse grading response",
        }

    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse grading result: {e}")
        return {
            "result": GradeResponse(
                score=0,
                is_correct=False,
                feedback=f"Error parsing response: {e}",
                suggestions=[],
            ),
            "error": str(e),
        }
    except Exception as e:
        logger.error(f"Error grading answer: {e}")
        return {
            "result": GradeResponse(
                score=0,
                is_correct=False,
                feedback=f"Error: {e}",
                suggestions=[],
            ),
            "error": str(e),
        }


def build_grade_graph() -> StateGraph:
    """Build the grade workflow graph.

    Workflow:
    START -> grade_answer -> END

    Returns:
        Compiled StateGraph for grade workflow
    """
    workflow = StateGraph(GradeState)

    # Add nodes
    workflow.add_node("grade_answer", grade_answer)

    # Set entry point
    workflow.set_entry_point("grade_answer")

    # Add edge to end
    workflow.add_edge("grade_answer", END)

    return workflow.compile()


# Type alias for the compiled graph
GradeGraph = StateGraph


async def run_grade_workflow(
    question_content: str,
    question_answer: str,
    user_answer: str,
    ai_config: AiConfig,
    rubric: str | None = None,
) -> GradeState:
    """Run the grade workflow and return final state.

    Args:
        question_content: The question text
        question_answer: The correct answer/rubric
        user_answer: User's answer to grade
        ai_config: AI configuration for LLM calls
        rubric: Optional scoring rubric

    Returns:
        Final grade state with result
    """
    graph = build_grade_graph()

    initial_state: GradeState = {
        "question_content": question_content,
        "question_answer": question_answer,
        "user_answer": user_answer,
        "rubric": rubric,
        "result": None,
        "error": None,
        "ai_config": ai_config,
    }

    final_state = await graph.ainvoke(initial_state)
    return final_state
