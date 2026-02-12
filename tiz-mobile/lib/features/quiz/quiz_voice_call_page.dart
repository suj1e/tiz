import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../theme/theme_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../ai/providers/ai_config_provider.dart';
import '../../../core/services/speech_service.dart';
import '../../../quiz/models/quiz_models.dart';
import '../../../quiz/models/quiz_category.dart';
import '../../../quiz/models/quiz_difficulty.dart';

/// Voice Call State Enum
enum VoiceCallState {
  idle,
  ringing,
  inCall,
  ended,
  error,
}

/// Quiz Voice Call Page
/// AI-powered voice call quiz interface for interactive learning
/// Features:
/// - Text-to-speech for AI quiz questions
/// - Speech-to-text for user voice answers
/// - Call state management (ringing, in-call, ended)
/// - Error handling for network/permission issues
/// - Visual feedback during voice call (waveform, status indicators)
class QuizVoiceCallPage extends StatefulWidget {
  final QuizCategory category;

  const QuizVoiceCallPage({
    super.key,
    required this.category,
  });

  @override
  State<QuizVoiceCallPage> createState() => _QuizVoiceCallPageState();
}

class _QuizVoiceCallPageState extends State<QuizVoiceCallPage>
    with TickerProviderStateMixin {
  // Call state
  VoiceCallState _callState = VoiceCallState.idle;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isAiSpeaking = false;
  bool _isListeningToUser = false;
  String? _errorMessage;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalQuestions = 5;

  // Question and answer
  QuizQuestion? _currentQuestion;
  String _userTranscript = '';
  bool _showResult = false;
  bool _waitingForAnswer = false;

  late AnimationController _waveController;
  late AnimationController _pulseController;
  final SpeechService _speechService = SpeechService.instance;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Initialize speech service
    _initializeSpeechService();
  }

  /// Initialize speech service with callbacks
  Future<void> _initializeSpeechService() async {
    _speechService.setCallbacks(
      onListeningStart: () {
        if (mounted) {
          setState(() => _isListeningToUser = true);
        }
      },
      onResult: (text) {
        if (mounted) {
          setState(() {
            _userTranscript = text;
            _isListeningToUser = false;
          });
          _processVoiceAnswer(text);
        }
      },
      onPartialResult: (text) {
        if (mounted) {
          setState(() => _userTranscript = text);
        }
      },
      onListeningEnd: () {
        if (mounted) {
          setState(() => _isListeningToUser = false);
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = error;
            _isListeningToUser = false;
          });
        }
      },
      onSpeakStart: () {
        if (mounted) {
          setState(() => _isAiSpeaking = true);
        }
      },
      onSpeakComplete: () {
        if (mounted) {
          setState(() => _isAiSpeaking = false);
          // After AI finishes speaking, start listening for user answer
          if (_waitingForAnswer && !_isMuted) {
            _startListeningForAnswer();
          }
        }
      },
      onSpeakError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = error;
            _isAiSpeaking = false;
          });
        }
      },
    );

    final initialized = await _speechService.initialize();
    if (!initialized && mounted) {
      setState(() {
        _errorMessage = '语音服务初始化失败';
        _callState = VoiceCallState.error;
      });
    }

    // Set TTS language based on category
    await _setTtsLanguage();
  }

  /// Set TTS language based on quiz category
  Future<void> _setTtsLanguage() async {
    String language;
    switch (widget.category) {
      case QuizCategory.english:
        language = 'en-US';
        break;
      case QuizCategory.japanese:
        language = 'ja-JP';
        break;
      case QuizCategory.german:
        language = 'de-DE';
        break;
    }
    await _speechService.setTtsLanguage(language);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _speechService.reset();
    super.dispose();
  }

  /// Start voice call
  Future<void> _startCall() async {
    // Check microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = '需要麦克风权限才能进行语音通话';
        _callState = VoiceCallState.error;
      });
      return;
    }

    // Start ringing state
    setState(() {
      _callState = VoiceCallState.ringing;
    });

    // Simulate ringing then start call
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _callState = VoiceCallState.inCall;
      _currentQuestionIndex = 0;
      _score = 0;
    });

    _nextQuestion();
  }

  /// End voice call
  Future<void> _endCall() async {
    await _speechService.stop();
    await _speechService.stopListening();

    setState(() {
      _callState = VoiceCallState.ended;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Move to next question
  void _nextQuestion() {
    if (_currentQuestionIndex >= _totalQuestions) {
      _showFinalResults();
      return;
    }

    final questions = _getQuestionsForCategory();
    if (_currentQuestionIndex < questions.length) {
      final question = questions[_currentQuestionIndex];
      setState(() {
        _currentQuestion = question;
        _showResult = false;
        _userTranscript = '';
        _errorMessage = null;
      });

      // Speak the question using TTS
      _speakQuestion(question);
    }
  }

  /// Speak question using TTS
  Future<void> _speakQuestion(QuizQuestion question) async {
    if (_isMuted) {
      setState(() {
        _waitingForAnswer = true;
        _isAiSpeaking = false;
      });
      return;
    }

    setState(() {
      _waitingForAnswer = true;
    });

    // Speak the question text
    final speechText = _getQuestionSpeechText(question);
    await _speechService.speak(speechText);
  }

  /// Get speech text for question (with options)
  String _getQuestionSpeechText(QuizQuestion question) {
    final buffer = StringBuffer();

    // Question number
    buffer.write('Question ${_currentQuestionIndex + 1}. ');

    // The question
    buffer.write(question.question);

    // Read options
    buffer.write('. Options: ');
    for (int i = 0; i < question.options.length; i++) {
      final letter = String.fromCharCode(65 + i); // A, B, C, D
      buffer.write('$letter. ${question.getOptionText(i)}');
      if (i < question.options.length - 1) {
        buffer.write(', ');
      }
    }

    return buffer.toString();
  }

  /// Process voice answer from user
  void _processVoiceAnswer(String transcript) {
    if (_currentQuestion == null || _showResult) return;

    final transcriptLower = transcript.toLowerCase();
    int? selectedAnswer;

    // Try to match answer letter (A, B, C, D) or number (1, 2, 3, 4)
    for (int i = 0; i < (_currentQuestion?.options.length ?? 4); i++) {
      final letter = String.fromCharCode(65 + i).toLowerCase();
      final number = (i + 1).toString();

      if (transcriptLower.contains(letter) || transcriptLower.contains(number)) {
        selectedAnswer = i;
        break;
      }
    }

    if (selectedAnswer != null) {
      _submitAnswer(selectedAnswer!);
    } else {
      // Could not understand, ask user to repeat or tap option
      setState(() {
        _errorMessage = '未识别到答案，请点击选项作答';
      });
    }
  }

  /// Submit answer
  void _submitAnswer(int answerIndex) {
    if (_currentQuestion == null || _showResult) return;

    final isCorrect = answerIndex == _currentQuestion!.correctAnswer;

    setState(() {
      _showResult = true;
      if (isCorrect) _score++;
      _waitingForAnswer = false;
      _errorMessage = null;
    });

    // Speak feedback
    _speakFeedback(isCorrect);

    // Move to next question after delay
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _currentQuestionIndex++;
        });
        _nextQuestion();
      }
    });
  }

  /// Speak feedback using TTS
  Future<void> _speakFeedback(bool isCorrect) async {
    String feedback;
    switch (widget.category) {
      case QuizCategory.english:
        feedback = isCorrect ? 'Correct!' : 'Incorrect.';
        break;
      case QuizCategory.japanese:
        feedback = isCorrect ? '正解！' : '不正解。';
        break;
      case QuizCategory.german:
        feedback = isCorrect ? 'Richtig!' : 'Falsch.';
        break;
    }
    await _speechService.speak(feedback);
  }

  /// Start listening for user's voice answer
  Future<void> _startListeningForAnswer() async {
    if (_isMuted) return;

    setState(() {
      _errorMessage = null;
    });

    // Set speech recognition locale based on category
    String locale;
    switch (widget.category) {
      case QuizCategory.english:
        locale = 'en-US';
        break;
      case QuizCategory.japanese:
        locale = 'ja-JP';
        break;
      case QuizCategory.german:
        locale = 'de-DE';
        break;
    }

    await _speechService.setLocale(locale);
    await _speechService.startListening(
      pauseFor: 10,
      partialResults: true,
    );
  }

  /// Stop listening
  Future<void> _stopListening() async {
    await _speechService.stopListening();
    if (mounted) {
      setState(() => _isListeningToUser = false);
    }
  }

  /// Toggle mute
  void _toggleMute() async {
    if (_isMuted) {
      // Unmute
      await _speechService.setVolume(1.0);
      setState(() {
        _isMuted = false;
      });
    } else {
      // Mute
      await _speechService.stop();
      await _speechService.setVolume(0.0);
      setState(() {
        _isMuted = true;
      });
    }
  }

  /// Toggle speaker
  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // Note: Actual speaker routing may require platform-specific implementation
  }

  /// Show final results
  void _showFinalResults() {
    setState(() {
      _callState = VoiceCallState.ended;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => _buildResultsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.text),
          onPressed: () => _callState == VoiceCallState.inCall ? _endCall() : Navigator.of(context).pop(),
        ),
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(colors),
    );
  }

  String _getAppBarTitle() {
    switch (_callState) {
      case VoiceCallState.idle:
        return '语音通话练习';
      case VoiceCallState.ringing:
        return '正在呼叫...';
      case VoiceCallState.inCall:
        return '${_currentQuestionIndex + 1}/$_totalQuestions';
      case VoiceCallState.ended:
        return '通话结束';
      case VoiceCallState.error:
        return '错误';
    }
  }

  Widget _buildBody(ThemeColors colors) {
    switch (_callState) {
      case VoiceCallState.idle:
        return _buildStartScreen(colors);
      case VoiceCallState.ringing:
        return _buildRingingScreen(colors);
      case VoiceCallState.inCall:
        return _buildCallContent(colors);
      case VoiceCallState.ended:
        return _buildStartScreen(colors);
      case VoiceCallState.error:
        return _buildErrorScreen(colors);
    }
  }

  Widget _buildStartScreen(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar with animation
          _buildAvatar(colors),
          const SizedBox(height: 24),
          Text(
            'AI语音通话练习',
            style: TextStyle(
              color: colors.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '与AI进行${_getCategoryName()}语音对话',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '共$_totalQuestions道题目',
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),
          // Start call button
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: _startCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.bg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                '开始通话',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Column(
              children: [
                _buildTip(Icons.headphones, '使用耳机获得更好体验', colors),
                const SizedBox(height: 12),
                _buildTip(Icons.volume_up, '确保麦克风权限已开启', colors),
                const SizedBox(height: 12),
                _buildTip(Icons.record_voice_over, '清晰朗读答案以获得识别', colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingingScreen(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(colors, isRinging: true),
          const SizedBox(height: 24),
          Text(
            '正在连接AI助手...',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: colors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '发生错误',
              style: TextStyle(
                color: colors.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? '未知错误',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _callState = VoiceCallState.idle;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.bg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '返回',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeColors colors, {bool isRinging = false}) {
    return AnimatedBuilder(
      animation: isRinging ? _pulseController : _waveController,
      builder: (context, child) {
        return Transform.scale(
          scale: isRinging ? 1.0 + (_pulseController.value * 0.1) : 1.0,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.border,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: colors.text,
              size: 48,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallContent(ThemeColors colors) {
    return Column(
      children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _currentQuestionIndex / _totalQuestions,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $_score',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${(_currentQuestionIndex / _totalQuestions * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // AI Avatar with wave animation
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAiAvatar(colors),
                const SizedBox(height: 20),
                // Status indicator
                _buildStatusIndicator(colors),
                // User transcript
                if (_userTranscript.isNotEmpty && !_showResult)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '识别: "$_userTranscript"',
                      style: TextStyle(
                        color: colors.textTertiary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Question Card
        if (!_showResult && _currentQuestion != null)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  _currentQuestion!.question,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Options grid
                ...List.generate(_currentQuestion!.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildOptionButton(index, colors),
                  );
                }),
              ],
            ),
          ),

        // Result or listening indicator
        if (_showResult)
          _buildResultSection(colors)
        else if (_isAiSpeaking)
          _buildAiSpeakingIndicator(colors)
        else if (_isListeningToUser)
          _buildListeningIndicator(colors),

        // Error message
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.error.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Control buttons
        _buildControlBar(colors),
      ],
    );
  }

  Widget _buildAiAvatar(ThemeColors colors) {
    return Stack(
      children: [
        // Wave animation
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(160, 80),
              painter: WavePainter(
                animation: _waveController,
                color: colors.accent.withOpacity(0.2),
              ),
            );
          },
        ),
        // Avatar container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colors.bgSecondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.border,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.smart_toy_rounded,
            color: _isAiSpeaking ? colors.accent : colors.text,
            size: 48,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(ThemeColors colors) {
    if (_isAiSpeaking) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWaveIndicator(colors),
            const SizedBox(width: 10),
            Text(
              'AI正在提问...',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    } else if (_waitingForAnswer) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              size: 14,
              color: _isMuted ? colors.textTertiary : colors.accent,
            ),
            const SizedBox(width: 10),
            Text(
              _isMuted ? '麦克风已静音' : '请回答...',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildOptionButton(int index, ThemeColors colors) {
    final letter = String.fromCharCode(65 + index); // A, B, C, D
    return GestureDetector(
      onTap: () => _submitAnswer(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              letter,
              style: TextStyle(
                color: colors.text,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentQuestion?.getOptionText(index) ?? '',
              style: TextStyle(
                color: colors.text,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(ThemeColors colors) {
    final correctAnswer = _currentQuestion?.correctAnswer ?? 0;
    final isCorrect = _score > _currentQuestionIndex;
    final questionsLeft = _totalQuestions - _currentQuestionIndex - 1;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? colors.accent : colors.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              isCorrect ? '回答正确!' : '回答错误',
              style: TextStyle(
                color: colors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              questionsLeft > 0
                  ? '还有$questionsLeft道题目'
                  : '测试即将完成',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSpeakingIndicator(ThemeColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWaveIndicator(colors),
          const SizedBox(width: 10),
          Text(
            'AI正在提问...',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningIndicator(ThemeColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic,
            size: 16,
            color: colors.accent,
          ),
          const SizedBox(width: 10),
          Text(
            '正在聆听你的回答...',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
            ),
          ),
          _buildListeningWave(colors),
        ],
      ),
    );
  }

  Widget _buildListeningWave(ThemeColors colors) {
    return SizedBox(
      width: 60,
      height: 20,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final animValue = ((_waveController.value + delay) % 1.0);
              final height = 6.0 + 12.0 * animValue;
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: colors.accent.withOpacity(0.5 + 0.5 * animValue),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildControlBar(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mute button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? '取消静音' : '静音',
            isActive: _isMuted,
            onTap: _toggleMute,
            colors: colors,
          ),
          const SizedBox(width: 40),
          // End call button
          GestureDetector(
            onTap: _endCall,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.call_end,
                color: colors.bg,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 40),
          // Speaker button
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            label: '扬声器',
            isActive: _isSpeakerOn,
            onTap: _toggleSpeaker,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    required ThemeColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? colors.accent.withOpacity(0.1) : colors.bgSecondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? colors.accent : colors.border,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? colors.accent : colors.text,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSheet() {
    final colors = context.watch<ThemeProvider>().colors;
    final percentage = (_score / _totalQuestions * 100).toStringAsFixed(0);
    final passed = _score >= (_totalQuestions * 0.6);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: passed ? colors.accent : colors.error,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  color: colors.bg,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            passed ? '恭喜通过!' : '继续加油',
            style: TextStyle(
              color: colors.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '答对 $_score/$_totalQuestions 题',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.bg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '返回',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!passed)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _score = 0;
                    _currentQuestionIndex = 0;
                    _callState = VoiceCallState.idle;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(color: colors.border, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '再试一次',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text, ThemeColors colors) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildWaveIndicator(ThemeColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final delay = index * 0.15;
        final animValue = ((_waveController.value + delay) % 1.0);
        final width = 4.0 + 8.0 * animValue;

        return Container(
          width: width,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  String _getCategoryName() {
    switch (widget.category) {
      case QuizCategory.english:
        return '英语';
      case QuizCategory.japanese:
        return '日语';
      case QuizCategory.german:
        return '德语';
    }
  }

  List<QuizQuestion> _getQuestionsForCategory() {
    return mockQuestions[widget.category] ?? [];
  }
}

/// Wave Painter for animation
class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  WavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final y = size.height / 2;

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;
      final waveHeight = 8.0 + 16.0 * (0.5 + 0.5 * animation.value);
      final waveOffset = 20.0 * normalizedX;

      final yOffset = waveHeight * (0.5 + 0.5 * (animation.value + normalizedX) % 1.0);

      if (x == 0) {
        path.moveTo(x, y + yOffset);
      } else {
        path.lineTo(x, y + yOffset);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.color != color;
}
