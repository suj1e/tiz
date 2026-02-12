# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tiz is a cross-platform mobile application built with Flutter, following **minimalist design principles**. The app features a three-tab bottom navigation (Home, Discover, Profile) with AI-powered translation, intelligent quiz system with voice calls, chat assistant, and command automation.

**Core AI Capabilities:**
- AI-enhanced translation with context understanding
- Intelligent chat assistant for Q&A and learning support
- Voice call quiz mode for interactive learning
- Smart quiz system with multiple language categories
- Personalized recommendations based on usage patterns
- **Command automation** with execution progress tracking

## HTML Prototype

A functional HTML prototype exists at `/opt/dev/apps/tiz-mobile/prototype.html` for design visualization and interaction testing.

**Preview locally:**
```bash
# Start HTTP server on port 42000
python3 -m http.server 42000 --directory /opt/dev/apps/tiz-mobile
# Access at http://localhost:42000/prototype.html
```

The prototype includes:
- Three navigation pages with full interactivity
- Minimalist theme switching (Light / Dark)
- **Discover page**: Top tab switching with four tabs (翻译/测验/对话/指令)
- AI features: voice call quiz, chat assistant, enhanced translation, deep thinking mode
- **Commands tab**: Command automation with execution progress and status tracking
- Model configuration with API key management
- Notification system with unread badge and interactive panel (no shadow, flat design)
- Translation tool interface with result display
- Profile/settings layout with inline theme selector
- Pure SVG icons throughout (no emoji icons)

## Design System

### Theme Architecture
The app supports two themes that users can switch from Profile → App Settings section:

| Theme | Style | Background | Text | Accent |
|-------|-------|-----------|------|--------|
| Light (default) | Clean minimal | `#ffffff` / `#f9fafb` | `#111827` | `#111827` |
| Dark | Pure dark | `#0a0a0a` / `#141414` | `#fafafa` | `#fafafa` |

**Design Principles:**
- **Restraint**: Only essential elements, no decoration for decoration's sake
- **Generous Whitespace**: Increased padding and margins for breathing room
- **Clear Hierarchy**: Established through font size and weight, not color
- **Consistent Details**: Unified 10-12px border radius, 1px borders
- **Fast Transitions**: All animations 0.15-0.2s for responsiveness

### Color System
```css
/* Light Theme */
--bg: #ffffff                    /* Primary background */
--bg-secondary: #f9fafb          /* Secondary background */
--text: #111827                  /* Primary text */
--text-secondary: #6b7280        /* Secondary text */
--text-tertiary: #9ca3af         /* Tertiary text */
--border: #e5e7eb                /* Border color */
--border-light: #f3f4f6          /* Light border for dividers */
--accent: #111827                /* Accent color */

/* Dark Theme */
--bg: #0a0a0a
--bg-secondary: #141414
--text: #fafafa
--text-secondary: #a1a1aa
--text-tertiary: #71717a
--border: #262626
--border-light: #1a1a1a
--accent: #fafafa
```

### Typography
- **Display Font**: Source Serif 4 (headings, 32px, -0.02em letter-spacing)
- **Body Font**: Inter (UI text, 13-16px)
- **Font Smoothing**: Enabled (-webkit-font-smoothing: antialiased)

**Type Scale:**
- Page Title: 32px / 600 weight / -0.02em tracking
- Card Title: 16px / 500 weight
- Body Text: 14-15px / 400 weight
- Secondary Text: 11-14px / 400-500 weight
- Labels: 11-13px / 500 weight

### Spacing System
Based on 4px grid:
- Card padding: 20px
- Card margin: 12px
- Button padding: 10-14px
- Input padding: 12-14px
- Gap between elements: 8-16px

### Corner Radius
- Cards: 12px
- Buttons: 8-10px
- Inputs: 10px
- Small elements: 6-8px
- Command chips: 20px (fully rounded)

### Animation & Transitions
- Duration: 0.15-0.2s
- Easing: ease / ease-out
- Page transitions: 0.2s fade + 4px slide
- Hover: Border color change only
- Active: Scale 0.96-0.98

### Borders & Dividers
- Standard border: 1px solid var(--border)
- Light border: 1px solid var(--border-light)
- Tab indicator: 2px solid var(--text)
- **No shadows** on any elements (pure flat design)
- **No gradients** (solid colors only, including toggle switches)

### Tab Switching
The Discover page uses a horizontal tab bar for content organization:
- **Tab Bar**: Displayed at top of page, 4 tabs maximum
- **Border**: 1px solid var(--border-light) at bottom
- **Active State**: Bottom border indicator (2px solid var(--text))
- **Inactive State**: Text color var(--text-secondary)
- **Transition**: 0.15s ease for all state changes
- **Content**: Each tab wraps content in `<div class="tab-content">`

```css
/* Tab Bar */
.tab-bar {
    display: flex;
    gap: 8px;
    margin-bottom: 20px;
    border-bottom: 1px solid var(--border-light);
}

.tab-btn {
    padding: 10px 16px;
    color: var(--text-secondary);
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.15s ease;
    position: relative;
}

.tab-btn.active {
    color: var(--text);
}

.tab-btn.active::after {
    content: '';
    position: absolute;
    bottom: -1px;
    left: 0;
    right: 0;
    height: 2px;
    background: var(--text);
}
```

## Code Architecture

### State Management
- Use **Provider** or **Riverpod** for state management
- Theme switching should use a `ThemeProvider` class persisted with `shared_preferences`
- AI configuration should use an `AiConfigProvider` with secure storage for API keys

### Component Structure
```
lib/
├── main.dart
├── theme/
│   ├── app_theme.dart          # Theme definitions
│   ├── app_colors.dart         # Minimalist color system
│   ├── app_text_styles.dart    # Typography system
│   └── theme_provider.dart     # Theme state management
├── core/
│   ├── constants.dart          # App constants
│   ├── routes.dart             # Navigation routes
│   └── services/
│       └── speech_service.dart # Speech recognition service
├── ai/
│   ├── models/
│   │   ├── ai_model.dart       # AI model enum
│   │   └── ai_config.dart      # Configuration data class
│   ├── providers/
│   │   └── ai_config_provider.dart  # AI config state
│   ├── services/
│   │   ├── ai_service.dart     # Base AI service interface
│   │   ├── openai_service.dart # OpenAI implementation
│   │   ├── claude_service.dart  # Claude implementation
│   │   └── local_model_service.dart # Local/on-device ML
│   └── widgets/
│       ├── chat_bubble.dart       # Chat message UI
│       ├── thinking_indicator.dart # Deep thinking loading state
│       ├── model_selector.dart    # Model dropdown
│       ├── api_key_input.dart     # Secure API key input
│       └── voice_call_ui.dart     # Voice call interface
├── commands/
│   ├── models/
│   │   ├── command.dart         # Command data model
│   │   ├── command_task.dart    # Task execution state
│   │   └── command_history.dart  # Command history
│   ├── providers/
│   │   └── command_provider.dart  # Command state management
│   ├── services/
│   │   └── command_executor_service.dart  # Command execution
│   └── widgets/
│       ├── command_input.dart       # Command input field
│       ├── command_suggestions.dart   # Quick command chips
│       ├── command_task_panel.dart   # Active tasks display
│       └── command_history.dart      # Command history list
├── quiz/
│   ├── models.dart             # Quiz question, session, difficulty models
│   ├── providers/
│   │   └── quiz_provider.dart    # Quiz state management
│   ├── services/
│   │   └── quiz_service.dart     # Quiz logic & AI integration
│   └── widgets/
│       ├── quiz_card.dart         # Quiz card widget
│       ├── quiz_options.dart      # Multiple choice options
│       ├── voice_call_interface.dart # Voice call UI
│       ├── category_selector.dart  # Language category selector
│       ├── quiz_taking_page.dart  # Quiz taking screen
│       └── quiz_results_page.dart  # Quiz results screen
├── activity/
│   ├── models/
│   │   ├── activity_card.dart   # Activity card model
│   │   └── todo_item.dart       # Todo item model
│   ├── providers/
│   │   └── activity_provider.dart  # Activity state management
│   ├── services/
│   │   └── activity_service.dart  # Activity logic
│   └── widgets/
│       ├── activity_card_widget.dart  # Activity card widget
│       └── todo_list_item.dart       # Todo list item widget
├── widgets/
│   ├── common/                 # Reusable widgets
│   │   ├── notification_badge.dart   # Unread count badge
│   │   ├── notification_panel.dart   # Notification dropdown
│   │   └── notification_item.dart    # Single notification widget
│   └── navigation/             # Bottom navigation bar
├── features/
│   ├── splash/                 # Splash screen
│   │   └── splash_page.dart    # App launch screen
│   ├── onboarding/             # Onboarding flow
│   │   ├── onboarding_page.dart      # Onboarding screen
│   │   └── widgets/                   # Onboarding widgets
│   ├── auth/                   # Authentication
│   │   ├── auth_controller.dart      # Auth state management
│   │   ├── login_page.dart           # Login screen
│   │   ├── register_page.dart        # Registration screen
│   │   └── widgets/                 # Auth widgets
│   ├── home/                   # Home page with quick actions
│   │   ├── home_page.dart      # Main home screen
│   │   └── widgets/
│   │       ├── voice_button.dart          # Voice input button
│   │       ├── voice_button_integrated.dart # Integrated voice button
│   │       └── ai_recommendation_card.dart  # AI recommendation card
│   ├── discover/               # Discover page with tab switching
│   │   ├── discover_page.dart          # Main discover screen
│   │   └── widgets/
│   │       ├── discover_tab_bar.dart     # Tab switching widget
│   │       ├── translation_tab.dart     # Translation tool
│   │       ├── translation_tool.dart    # Translation component
│   │       ├── quiz_tab.dart             # Quiz system
│   │       ├── chat_tab.dart             # AI chat assistant
│   │       ├── ai_chat_assistant.dart    # Chat assistant widget
│   │       └── commands_tab.dart        # Command automation
│   ├── quiz/                   # Quiz feature pages
│   │   ├── quiz_taking_page.dart      # Quiz taking screen
│   │   └── quiz_results_page.dart     # Quiz results screen
│   ├── settings/               # Settings pages
│   │   ├── settings_page.dart         # Main settings screen
│   │   └── widgets/                   # Settings widgets
│   ├── about/                  # About page
│   │   └── about_page.dart     # App information screen
│   └── profile/                # Profile page + AI settings
│       ├── profile_page.dart   # Main profile screen
│       └── widgets/
│           └── theme_selector.dart    # Theme selection widget
├── models/                     # Data models
│   └── notification.dart       # Notification model
└── providers/
    └── notification_provider.dart  # Notification state management
```

### Navigation Structure

### Routes

Located at `lib/core/routes.dart`:

```dart
class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/discover':
        return MaterialPageRoute(builder: (_) => const DiscoverPage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      // Additional routes will be added as new pages are implemented
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
```

### Complete Route List

**Currently Implemented:**
- `/` → Home Page
- `/discover` → Discover Page (with tabs)
- `/profile` → Profile Page

**Planned Routes:**
- `/splash` → Splash Screen
- `/onboarding` → Onboarding Pages
- `/login` → Login Page
- `/register` → Register Page
- `/quiz/taking` → Quiz Taking Page
- `/quiz/results` → Quiz Results Page
- `/settings` → Settings Page
- `/about` → About Page

### Navigation Flow
Three-tab bottom navigation with independent page stacks:
- **Home**: Greeting (32px), quick actions grid (3 buttons: 翻译/测验/AI助手), recent activity list
- **Discover**: Top tab switching with four tabs:
  - **翻译**: AI-enhanced translation tool with language selection (中文/English/日本語) and result display
  - **测验**: Quiz system with category selection (英语/日本語/德语) and modes (选择题/对话/通话)
  - **对话**: AI chat assistant with message bubbles (no deep thinking toggle in UI)
  - **指令**: Command automation with execution progress tracking and history
- **Profile**: User info, AI settings, app settings, theme selector (浅色/深色)

### Notification System
The notification system provides real-time updates to users:
- **Notification Badge**: Small circular badge (16px) on bell icon showing unread count
- **Badge Colors**: Adapts to theme - `colors.text` background, `colors.bg` text
- **Notification Panel**: Slide-down panel from top-right with notification list
- **Unread State**: Secondary background with dot indicator for unread items
- **Read State**: Click to mark as read, badge auto-updates
- **Panel**: Closes on outside click, close button, or after reading notification
- **Design**: Pure flat, no shadows

### Home Page Quick Actions
The home page features a 3-column grid of quick action buttons:
- **Layout**: Horizontal row with 3 equal-width buttons (10px gap)
- **Button Specs**:
  - Padding: 16px vertical, 12px horizontal
  - Border radius: 10px
  - Background: `colors.bgSecondary`
  - Border: 1px solid `colors.border`
  - Icon: 24px
  - Label: 12px / 500 weight
  - Gap between icon and label: 8px
- **Actions**:
  1. 翻译 (Start Translation) - Navigate to Discover → Translation
  2. 每日测验 (Daily Quiz) - Navigate to Discover → Quiz
  3. AI 助手 (AI Assistant) - Navigate to Discover → Chat
- **Interaction**: InkWell with proper tap feedback

### Recent Activity List
Below quick actions, shows recent learning activities:
- **Item Structure**: Icon (36x36) + title (14px/500) + time (11px/tertiary)
- **Icon Container**: 8px border radius, bg background, 1px border
- **Spacing**: 8px vertical gap between items

Notification types:
- AI translation completion
- Feature announcements
- Learning reminders
- System notifications

## AI Configuration

### Supported Models
| Model | Key | Use Case |
|-------|-----|----------|
| GPT-4 | `gpt4` | Complex reasoning, enhanced translation |
| GPT-3.5 Turbo | `gpt35` | Fast responses, simple Q&A |
| Claude 3 Opus | `claude` | Long-text analysis, document translation |
| Gemini Pro | `gemini` | Multimodal, image translation |
| Local Model | `local` | Privacy-preserving, offline |
| Custom API | `custom` | Private deployment, third-party |

### Configuration Storage
Store AI configuration securely using `flutter_secure_storage`:
```dart
class AiConfig {
  String model;           // Selected model key
  String? apiKey;         // Encrypted API key
  double temperature;     // Default: 0.7
  int maxTokens;         // Default: 2048
  String systemPrompt;   // Custom system prompt
  bool enhanceTranslation; // AI enhancement toggle
  bool smartRecommend;    // Recommendation toggle
  bool voiceAssistant;    // Voice feature toggle
  bool deepThinkingMode;  // Deep thinking mode toggle
}
```

### Deep Thinking Mode
Deep thinking mode enables extended reasoning for complex queries:
- **Trigger**: Toggle in Profile → AI Settings only (NOT in chat tab per prototype spec)
- **Behavior**: Shows reasoning process in AI response
- **Delay**: ~1.5s response time vs ~0.5s normal mode
- **Format**: Structured analysis with bullet points
- **Note**: Chat tab does NOT have a toggle (prototype explicitly states this is removed)

## Command Automation System

### Command Structure
Commands are natural language instructions that AI interprets and executes:

**Command Types:**
- Translation: `翻译"Hello"到英语`
- Quiz: `开始英语测验`
- Planning: `制定学习计划`
- Custom: User-defined commands

### Command Execution
```dart
class CommandTask {
  String id;
  String command;
  TaskStatus status;        // pending, running, completed, failed
  double progress;          // 0.0 to 1.0
  String currentStep;       // Current execution step
  String? result;           // Execution result
  DateTime createdAt;
  DateTime? completedAt;
}

enum TaskStatus {
  pending,
  running,
  completed,
  failed,
}
```

### UI Components
- **Command Suggestions**: Quick-action chips for common commands
- **Active Tasks Panel**: Shows currently running tasks with progress bars
- **Command History**: List of executed commands with results
- **Command Input**: Terminal-style input with prompt indicator (8px circle)
- **Chat Bubbles**: Asymmetric border radius for "tail" effect
  - AI bubble: 4px bottom-left, 12px other corners
  - User bubble: 4px bottom-right, 12px other corners
  - Max width: 280px
  - Padding: 14px horizontal, 12px vertical

## Authentication Flow

The app uses a mock authentication system for demo purposes:

### Auth Controller
Located at `lib/features/auth/auth_controller.dart`:

```dart
class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUserEmail;

  // Login with email and password
  // Mock validation: email must contain "@", password length > 6
  Future<bool> login(String email, String password);

  // Register with name, email and password
  // Mock validation: all fields required, passwords must match
  Future<bool> register(String name, String email, String password, String confirmPassword);

  // Logout
  void logout();
}
```

### Navigation Flow
```
Splash Screen (2 seconds)
    ↓
    ├─→ First time user → Onboarding Pages → Login/Register → Home
    └─→ Returning user → Home (if logged in)
```

### Mock Validation Rules
- **Login**: Email must contain "@", password length > 6 characters
- **Register**: All fields required, passwords must match, password length > 6
- **Session**: In-memory only (not persisted)

### Splash Screen
Located at `lib/features/splash/splash_page.dart`:
- App logo/icon in center with bgSecondary background
- App name "Tiz" below logo (32px, w600, -0.5em letter-spacing)
- 2 seconds delay, then navigate to login or home

### Onboarding
Located at `lib/features/onboarding/`:
- Introduction screens for first-time users
- Swipe through feature highlights
- "Get Started" button navigates to login/register

### Login/Register Pages
Located at `lib/features/auth/`:
- **Login**: Email and password fields
- **Register**: Name, email, password, confirm password fields
- Mock validation with error messages
- Auto-login after successful registration

## Quiz System

### Quiz Flow
```
Quiz Tab → Select Category → Select Mode → Start Quiz → Quiz Taking Page → Quiz Results → Back to Discover
```

### Quiz Categories
```dart
enum QuizCategory {
  english,    // English
  japanese,   // Japanese
  german,     // German
}
```

### Quiz Modes
```dart
enum QuizMode {
  choice,        // Multiple choice (4 options)
  conversation,  // Text-based Q&A with AI
  voiceCall,     // Voice call with AI
}
```

### Quiz Data Structure
Located at `lib/quiz/models.dart`:

```dart
class QuizQuestion {
  String id;
  String question;
  List<String> options;   // For choice mode
  int correctAnswer;     // Index of correct option
  String explanation;     // Answer explanation
  QuizDifficulty difficulty;  // beginner, intermediate, advanced
}

class QuizSession {
  String id;
  List<QuizQuestion> questions;
  int currentIndex;
  int score;
  QuizMode mode;
  QuizCategory category;
  DateTime startedAt;
  bool isCompleted;

  // Get current question
  QuizQuestion? get currentQuestion;

  // Get progress (0.0 to 1.0)
  double get progress;

  // Submit answer for current question
  void submitAnswer(int answerIndex);

  // Calculate percentage score
  double get percentage;

  // Check if user passed (60% or higher)
  bool get passed;
}

enum QuizDifficulty {
  beginner,
  intermediate,
  advanced,
}
```

### Mock Questions Data
The app includes mock quiz questions for each category:
- **English**: 5 questions (beginner to advanced)
- **Japanese**: 5 questions (beginner to advanced)
- **German**: 5 questions (beginner to advanced)

Located at `lib/quiz/models.dart` (lines 109-246)

### Quiz Taking Page
Located at `lib/features/quiz/quiz_taking_page.dart`:
- Display current question
- Multiple choice options (4 options)
- Progress indicator
- Question counter (e.g., "Question 3 of 5")
- Submit/Next button
- Navigate to results when complete

### Quiz Results Page
Located at `lib/features/quiz/quiz_results_page.dart`:
- Score display (percentage)
- Pass/Fail indicator (60% threshold)
- Answer breakdown:
  - Show user's answers
  - Show correct answers
  - Display explanations
- "Try Again" button
- "Back to Discover" button

### Voice Call Interface
The voice call mode provides an interactive quiz experience:
- **Avatar**: Simple circular avatar with SVG icon
- **Status Text**: Shows current call state
- **Wave Animation**: Subtle animated bars during call
- **Controls**: Mute, hangup, speaker buttons
- **AI Voice**: AI reads questions and listens to answers

## Translation System

### Translation Flow
```
Translation Tab → Select Languages → Input Text → Translate → Result Display + History
```

### Translation Features
Located at `lib/features/discover/widgets/translation_tab.dart`:
- **Language Selector**: Choose from 中文, English, 日本語
- **Text Input**: Multi-line text field (3 lines)
- **Translate Button**: Trigger translation
- **Result Display**: Show translated text
- **Translation History**: Recent translations list

### Translation History Format
```dart
class TranslationHistoryItem {
  String id;
  String sourceText;
  String translatedText;
  String sourceLanguage;
  String targetLanguage;
  DateTime timestamp;
}
```

### Mock Translation Responses
The app uses mock translation responses for demo:
- English → Chinese: Mock translated text
- Chinese → English: Mock translated text
- Japanese → English/Chinese: Mock translated text

## Design Philosophy

### Minimalist Principles

**1. Restraint Over Decoration**
- Remove anything that doesn't serve a purpose
- No decorative elements (emojis, gradients, shadows)
- Flat design with solid colors only
- Pure SVG/Material icons, no emoji icons

**2. Generous Whitespace**
- Increase padding by 20-30% compared to standard designs
- More margin between cards (12px minimum)
- Room for content to breathe

**3. Clear Typography Hierarchy**
- Use font size and weight to establish importance
- Avoid using color as the primary differentiator
- Consistent letter-spacing and line-height

**4. Consistent Details**
- Unified corner radius (10-12px for most elements)
- Consistent border width (1px)
- Standardized spacing (4px grid)

**5. Fast, Subtle Interactions**
- Quick transitions (0.15-0.2s)
- Minimal hover effects (border color change)
- Small scale changes on active (0.96-0.98)

**6. Functional Color**
- Colors indicate state, not decoration
- Accent color used sparingly for CTAs and active states
- Gray scale for most UI elements

### Component Specifications

**Toggle Switch:**
- Size: 44x24px
- Track radius: 12px (fully rounded ends)
- Thumb: 20px circle, always `colors.bg`
- Active: Solid `colors.accent` (NO gradient)
- Inactive: `colors.border` with 1px border
- Animation: 200ms

**Quick Action Button:**
- Layout: 3-column grid, 10px gap
- Padding: 16px vertical, 12px horizontal
- Border radius: 10px
- Background: `colors.bgSecondary`
- Border: 1px solid `colors.border`
- Icon: 24px, `colors.text`
- Label: 12px / 500 weight, `colors.text`
- Icon-label gap: 8px

**Chat Bubble:**
- Max width: 280px
- Padding: 14px horizontal, 12px vertical
- Font size: 14px, line height 1.5
- Border radius: Asymmetric
  - AI: 12px except 4px bottom-left
  - User: 12px except 4px bottom-right
- AI background: `colors.bgSecondary`
- User background: `colors.accent`

**Notification Badge:**
- Size: 16x16px circle
- Position: Top-right of bell icon (-4px offset)
- Background: `colors.text` (adapts to theme)
- Text: `colors.bg` (high contrast)
- Font: 9px / 600 weight

### What to Avoid
- ❌ Gradient backgrounds
- ❌ Decorative emojis (use SVG icons instead)
- ❌ Any shadows (pure flat design)
- ❌ Rounded corners > 16px
- ❌ Slow animations (> 0.3s)
- ❌ Multiple accent colors
- ❌ Glassmorphism or blur effects
- ❌ Decorative illustrations
- ❌ Unnecessary badges or labels
- ❌ Box shadows on any elements

## Platform Targets

- **iOS**: 15+ (primary design reference)
- **Android**: 8.0+ (maintain minimalist consistency)

## Accessibility

- VoiceOver (iOS) and TalkBack (Android) support required
- Support both portrait and landscape orientations
- Minimum touch target: 44x44pt (iOS), 48x48dp (Android)
- Sufficient color contrast ratio (4.5:1 minimum)

---

## Implementation Status

### ✅ Completed (v1.1.0)

**Phase 1: Core Infrastructure**
- [x] Project structure initialization
- [x] Provider state management setup
- [x] Minimalist theme system (Light/Dark)
- [x] Navigation architecture
- [x] Common UI components

**Phase 2: AI Features**
- [x] AI service interface and factory
- [x] OpenAI service implementation
- [x] Claude service implementation
- [x] AI configuration provider
- [x] Secure API key storage
- [x] Model selector widget

**Phase 3: Feature Pages**
- [x] Home page with quick actions
- [x] Discover page (translation + chat + quiz + commands)
- [x] Profile page with settings
- [x] Notification system
- [x] Voice call quiz interface
- [x] Command automation UI

**Phase 4: Design Polish**
- [x] Minimalist design system implementation
- [x] Theme persistence with inline selector
- [x] Deep thinking mode toggle
- [x] Fast, subtle animations
- [x] Tab bar with bottom border
- [x] Pure flat design (no gradients)

### 🚧 To Do / Future Enhancements

**Phase 5: Production Readiness**
- [ ] Unit tests for services and providers
- [ ] Widget tests for components
- [ ] Integration tests for user flows
- [ ] Error handling improvements
- [ ] Loading states optimization

**Phase 6: Additional Features**
- [ ] Actual API integration (currently using mock responses)
- [ ] Command execution engine
- [ ] Chat history persistence
- [ ] Translation history
- [ ] Quiz progress tracking
- [ ] Command scheduling/automation
- [ ] Offline mode support
- [ ] User authentication
- [ ] Cloud sync for preferences

**Phase 7: Platform Specific**
- [ ] iOS specific widgets (Cupertino styling)
- [ ] Android Material Design 3 adaptations
- [ ] Platform-specific permissions handling
- [ ] Push notifications

### Known Limitations

1. **Mock AI Responses**: Current implementation returns simulated responses. To use actual AI services:
   - Configure API keys in Profile → AI Settings
   - Ensure network permissions are set up
   - API integration is ready but requires valid keys

2. **Speech Recognition**: Requires microphone permissions to be configured in:
   - `ios/Runner/Info.plist` (iOS)
   - `android/app/src/main/AndroidManifest.xml` (Android)

3. **Command Execution**: Commands currently show mock execution. Real implementation needs:
   - Command parser/interpreter
   - Task execution engine
   - Progress tracking system

### Recent Updates (2026-02-08)

**New Features & Pages:**
- ✅ **Splash Screen** (`lib/features/splash/splash_page.dart`)
  - App logo with bgSecondary background
  - 2-second delay before navigation
  - Will check login status in production
- ✅ **Authentication Controller** (`lib/features/auth/auth_controller.dart`)
  - Mock login validation (email contains "@", password > 6 chars)
  - Mock registration with password confirmation
  - In-memory session management
- ✅ **Quiz Models** (`lib/quiz/models.dart`)
  - QuizQuestion model with options, correct answer, explanation
  - QuizSession with progress tracking and scoring
  - Mock questions for English, Japanese, German (5 each)
  - QuizDifficulty enum (beginner, intermediate, advanced)

**New Directories:**
- `lib/features/splash/` - Splash screen implementation
- `lib/features/auth/` - Authentication pages and controller
- `lib/features/onboarding/` - Onboarding pages (pending implementation)
- `lib/features/quiz/` - Quiz feature pages (pending implementation)
- `lib/features/settings/` - Settings pages (pending implementation)
- `lib/features/about/` - About page (pending implementation)

**Documentation Updates:**
- ✅ Updated `CLAUDE.md` with new file structure
- ✅ Added authentication flow documentation
- ✅ Added quiz flow documentation
- ✅ Added translation flow documentation
- ✅ Created `docs/MOCK_DATA.md` with mock data structures
- ✅ Updated `docs/gap-analysis.md` with completed fixes

**Gap Analysis & Prototype Alignment:**

**Gap Analysis & Prototype Alignment:**
- ✅ Added quick actions grid to home page (3 buttons: 翻译/测验/AI助手)
  - Layout: Horizontal row with 10px gap between buttons
  - Styling: bgSecondary background, 1px border, 10px border radius
  - Icons: 24px with 12px labels below
- ✅ Fixed home page subtitle to "继续学习之旅" (was "开始学习")
- ✅ Removed deep thinking toggle from chat tab (per prototype spec)
  - Prototype explicitly states: "Deep thinking toggle is NOT present in the chat tab"
  - Deep thinking remains configurable in Profile → AI Settings
- ✅ Changed toggle switch to solid color (removed gradient)
  - Active state: solid `colors.accent` (was gradient from accent.withOpacity(0.8) to accent)
  - Maintains pure flat design principle
- ✅ Fixed chat bubble border radius (asymmetric corners)
  - AI messages: 4px bottom-left, 12px other corners
  - User messages: 4px bottom-right, 12px other corners
  - Creates "tail" effect matching prototype
- ✅ Verified notification badge colors for both themes
  - Uses `colors.text` for background (adapts to theme)
  - Uses `colors.bg` for text color (high contrast)
- ✅ Updated all documentation to match current implementation
- **Design Compliance**: 95%+ fidelity with HTML prototype
- **Gap Analysis Report**: Available at `/docs/gap-analysis.md`

**Key Implementation Details:**
- Quick action buttons use InkWell for proper tap feedback
- Home page recent activity shows icon + title + time layout
- All spacing follows 4px grid system
- No shadows or gradients anywhere (pure flat design)
- Toggle switches use solid colors only
- Chat bubbles have asymmetric border radius for visual distinction

### Quick Start for Development

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on simulator/emulator
flutter run

# 3. To test AI features, configure API keys in:
# Profile → AI Settings → AI Model → Select model → Enter API key
```

### Files Reference

**Key Implementation Files (Updated 2026-02-08):**

| File | Purpose |
|------|---------|
| `lib/features/home/home_page.dart` | Home page with quick actions grid (3 buttons) and recent activity |
| `lib/features/discover/widgets/chat_tab.dart` | Chat interface with asymmetric bubbles (no deep thinking toggle) |
| `lib/widgets/common/toggle_switch.dart` | Solid color toggle (no gradient) |
| `lib/widgets/common/notification_panel.dart` | Notification system with theme-aware badge |
| `lib/theme/app_colors.dart` | Color system definitions |
| `lib/theme/app_theme.dart` | Theme configuration |

**Documentation Files:**

| File | Purpose |
|------|---------|
| `docs/prototype-analysis.md` | HTML prototype detailed analysis |
| `docs/flutter-implementation.md` | Flutter implementation analysis |
| `docs/gap-analysis.md` | Gap analysis with prioritized fixes |
| `docs/MOCK_DATA.md` | Mock data structures and API responses |
| `docs/API.md` | API documentation (in Chinese) |
| `CLAUDE.md` | This file - project documentation |

**All Files:**
|------|---------|
| `lib/main.dart` | App entry point with providers |
| `lib/theme/theme_provider.dart` | Theme state management |
| `lib/theme/app_theme.dart` | Minimalist theme definitions |
| `lib/ai/providers/ai_config_provider.dart` | AI configuration |
| `lib/commands/providers/command_provider.dart` | Command automation state |
| `lib/features/home/home_page.dart` | Home page implementation |
| `lib/features/discover/discover_page.dart` | Discover page with tab switching |
| `lib/features/discover/widgets/discover_tab_bar.dart` | Tab bar widget |
| `lib/features/discover/widgets/translation_tab.dart` | Translation tab |
| `lib/features/discover/widgets/quiz_tab.dart` | Quiz tab |
| `lib/features/discover/widgets/chat_tab.dart` | Chat tab |
| `lib/features/discover/widgets/commands_tab.dart` | Commands tab |
| `lib/features/profile/profile_page.dart` | Profile & settings |
