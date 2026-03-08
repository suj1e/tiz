"""Prompt templates for LLM interactions."""

from functools import lru_cache


class Prompts:
    """Prompt templates for different tasks."""

    # Chat system prompt
    CHAT_SYSTEM = """你是一个专业的学习助手，帮助用户通过对话生成个性化的练习题目。

你的任务是：
1. 理解用户的学习需求和意图
2. 如果用户想要生成题目，确认并提取以下信息：
   - 主题/知识点
   - 题目数量（默认5道）
   - 难度等级（简单/中等/困难）
   - 题目类型（选择题/简答题）

当用户表达想要生成题目的意图时，回复格式如下：
[CONFIRM]
主题: <提取的主题>
数量: <题目数量>
难度: <难度等级>
类型: <题目类型>
[/CONFIRM]
<友好的确认消息>

否则，正常回复用户的问题。"""

    # Intent analysis prompt
    INTENT_ANALYSIS = """分析用户的意图，判断是否想要生成练习题目。

用户消息：{message}

历史对话：
{history}

如果用户想要生成题目，提取以下信息并以JSON格式返回：
{{
    "intent": "generate",
    "topic": "<主题>",
    "count": <数量>,
    "difficulty": "<难度>",
    "question_types": ["<类型1>", "<类型2>"]
}}

如果用户只是在聊天或询问问题，返回：
{{
    "intent": "chat"
}}"""

    # Question generation prompt
    GENERATE_QUESTIONS = """根据以下要求生成练习题目：

主题：{topic}
数量：{count}
难度：{difficulty}
题目类型：{question_types}

请以JSON格式返回题目列表：
{{
    "questions": [
        {{
            "type": "choice",
            "content": "题目内容",
            "options": ["选项A", "选项B", "选项C", "选项D"],
            "answer": "正确答案",
            "explanation": "答案解析"
        }},
        {{
            "type": "essay",
            "content": "题目内容",
            "answer": "参考答案",
            "rubric": "评分标准"
        }}
    ]
}}"""

    # Grading prompt
    GRADING = """你是一个专业的评分助手，需要评估用户的简答题答案。

题目：{question_content}
参考答案/评分标准：{question_answer}
用户答案：{user_answer}

请以JSON格式返回评分结果：
{{
    "score": <0-100的分数>,
    "is_correct": <true/false，是否正确>,
    "feedback": "<详细的反馈>",
    "suggestions": ["<改进建议1>", "<改进建议2>"]
}}

评分标准：
- 90-100分：答案完整准确
- 70-89分：答案基本正确但有遗漏
- 50-69分：答案部分正确
- 0-49分：答案错误或严重不完整"""

    @classmethod
    def format_chat_system(cls) -> str:
        """Get formatted chat system prompt."""
        return cls.CHAT_SYSTEM

    @classmethod
    def format_intent_analysis(cls, message: str, history: list[dict]) -> str:
        """Format intent analysis prompt."""
        history_str = "\n".join(
            f"{msg.get('role', 'user')}: {msg.get('content', '')}"
            for msg in history
        )
        return cls.INTENT_ANALYSIS.format(message=message, history=history_str or "无")

    @classmethod
    def format_generate_questions(
        cls,
        topic: str,
        count: int,
        difficulty: str,
        question_types: list[str],
    ) -> str:
        """Format question generation prompt."""
        return cls.GENERATE_QUESTIONS.format(
            topic=topic,
            count=count,
            difficulty=difficulty,
            question_types=", ".join(question_types),
        )

    @classmethod
    def format_grading(
        cls,
        question_content: str,
        question_answer: str,
        user_answer: str,
    ) -> str:
        """Format grading prompt."""
        return cls.GRADING.format(
            question_content=question_content,
            question_answer=question_answer,
            user_answer=user_answer,
        )


@lru_cache
def get_prompts() -> type[Prompts]:
    """Get prompts class (cached)."""
    return Prompts
