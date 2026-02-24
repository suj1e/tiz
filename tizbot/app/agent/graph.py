"""LangGraph Agent implementation."""

from typing import AsyncGenerator, TypedDict

from langgraph.graph import END, StateGraph

from app.services.llm import LLMProvider, get_llm_provider
from app.models.chat import MessageRole


class AgentState(TypedDict):
    """Agent state for LangGraph."""

    messages: list[dict]
    chat_id: str
    user_id: str
    should_respond: bool


class Agent:
    """LangGraph AI Agent."""

    def __init__(self, llm_provider: LLMProvider = None):
        self.llm_provider = llm_provider or get_llm_provider()
        self.graph = self._build_graph()

    def _should_respond(self, state: AgentState) -> str:
        """Determine if agent should respond."""
        # Always respond for now
        return "respond"

    def _respond(self, state: AgentState) -> AgentState:
        """Generate response using LLM."""
        # This is a placeholder - actual streaming happens in run method
        return state

    def _build_graph(self) -> StateGraph:
        """Build the LangGraph state machine."""
        graph = StateGraph(AgentState)

        # Add nodes
        graph.add_node("respond", self._respond)

        # Add edges
        graph.set_entry_point("respond")
        graph.add_edge("respond", END)

        return graph.compile()

    def _convert_to_llm_format(self, messages: list[dict]) -> list[dict]:
        """Convert messages to LLM format."""
        llm_messages = []
        for msg in messages:
            role = msg.get("role", "user")
            # Map internal roles to LLM roles
            if role == "assistant":
                role = "assistant"
            elif role == "system":
                role = "system"
            else:
                role = "user"
            llm_messages.append({
                "role": role,
                "content": msg.get("content", ""),
            })
        return llm_messages

    async def run_stream(
        self,
        chat_id: str,
        user_id: str,
        messages: list[dict],
    ) -> AsyncGenerator[str, None]:
        """Run the agent with streaming."""
        llm_messages = self._convert_to_llm_format(messages)
        async for token in self.llm_provider.chat_stream(llm_messages):
            yield token

    async def run(
        self,
        chat_id: str,
        user_id: str,
        messages: list[dict],
    ) -> str:
        """Run the agent without streaming."""
        llm_messages = self._convert_to_llm_format(messages)
        return await self.llm_provider.chat(llm_messages)


# Global agent instance
_agent: Agent = None


def get_agent() -> Agent:
    """Get or create global agent instance."""
    global _agent
    if _agent is None:
        _agent = Agent()
    return _agent
