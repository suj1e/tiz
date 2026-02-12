# Tiz Mobile App - HTML Prototype Analysis

**Date:** 2026-02-08
**Prototype File:** `/Users/sujie/workspace/dev/apps/tiz/tiz-mobile/prototype.html`
**Analysis Version:** 1.0

---

## Table of Contents

1. [Page Structure](#1-page-structure)
2. [Theme System](#2-theme-system)
3. [Home Page](#3-home-page)
4. [Discover Page - Tab System](#4-discover-page---tab-system)
5. [Tab Content Details](#5-tab-content-details)
6. [Profile Page](#6-profile-page)
7. [Notification System](#7-notification-system)
8. [Interaction Details](#8-interaction-details)
9. [SVG Icons](#9-svg-icons)
10. [JavaScript Functionality](#10-javascript-functionality)

---

## 1. Page Structure

### 1.1 Main App Container

```css
.app-container {
    max-width: 480px;
    margin: 0 auto;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}
```

**Key Details:**
- Mobile-first design with max-width of 480px
- Centered layout with auto margins
- Flex column layout for vertical stacking
- Full viewport height minimum

### 1.2 Content Area

```css
.content-area {
    flex: 1;
    padding: 24px 20px 100px;
}
```

**Spacing:**
- Top padding: 24px
- Horizontal padding: 20px
- Bottom padding: 100px (to accommodate bottom navigation)

### 1.3 Bottom Navigation

```css
.bottom-nav {
    position: fixed;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 100%;
    max-width: 480px;
    background: var(--bg);
    border-top: 1px solid var(--border);
    padding: 8px 0 20px;
    z-index: 100;
}
```

**Navigation Items (3 tabs):**
1. **首页** (Home) - Active state
2. **发现** (Discover)
3. **我的** (Profile)

**Icon Size:** 24x24px
**Label Font Size:** 11px
**Font Weight:** 500
**Gap between icon and label:** 4px

**Active State Styling:**
- Color: `var(--text)`
- Inactive color: `var(--text-secondary)`

### 1.4 Top Header Area

**Home Page Header:**
```css
.home-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 24px;
}
```

**Greeting Section:**
- Title: "你好" (32px, Source Serif 4, 600 weight)
- Subtitle: "继续学习之旅" (14px, Inter, 400 weight)

**Notification Button:**
- Size: 40x40px
- Border radius: 10px
- Background: `var(--bg-secondary)`
- Border: 1px solid `var(--border)`
- Contains notification badge (16x16px circle)

---

## 2. Theme System

### 2.1 Light Theme (Default)

```css
:root {
    --bg: #ffffff;
    --bg-secondary: #f9fafb;
    --text: #111827;
    --text-secondary: #6b7280;
    --text-tertiary: #9ca3af;
    --border: #e5e7eb;
    --border-light: #f3f4f6;
    --accent: #111827;
    --accent-text: #ffffff;
}
```

### 2.2 Dark Theme

```css
[data-theme="dark"] {
    --bg: #0a0a0a;
    --bg-secondary: #141414;
    --text: #fafafa;
    --text-secondary: #a1a1aa;
    --text-tertiary: #71717a;
    --border: #262626;
    --border-light: #1a1a1a;
    --accent: #fafafa;
    --accent-text: #0a0a0a;
}
```

### 2.3 Font System

**Primary Font:** Inter (UI text)
- Weights: 300, 400, 500, 600
- Google Fonts loaded via CDN

**Display Font:** Source Serif 4 (headings)
- Weights: 400, 600, 700
- Used for page titles (32px)

**Font Smoothing:**
```css
-webkit-font-smoothing: antialiased;
-moz-osx-font-smoothing: grayscale;
```

**Theme Transition:**
```css
transition: background 0.2s ease, color 0.2s ease;
```

---

## 3. Home Page

### 3.1 Greeting Section

**Layout:**
- Left side: Greeting text
  - Title: 32px, 600 weight, -0.02em letter-spacing
  - Subtitle: 14px, 400 weight, secondary text color
  - Bottom margin: 32px for subtitle

**Right Side:**
- Notification button (40x40px)
- Badge showing unread count

### 3.2 Quick Actions Card

```css
.quick-actions-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
}
```

**Three Action Buttons:**

1. **开始翻译** (Start Translation)
   - Icon: Language/translate icon
   - Label: "开始翻译"

2. **每日测验** (Daily Quiz)
   - Icon: Question mark in circle
   - Label: "每日测验"

3. **AI 助手** (AI Assistant)
   - Icon: Chat bubble
   - Label: "AI 助手"

**Button Styling:**
```css
.quick-action-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    padding: 16px 12px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    color: var(--text);
    font-size: 12px;
}
```

**Hover State:**
- Background: `var(--accent)`
- Text color: `var(--accent-text)`
- Border color: `var(--accent)`

**Active State:**
- Transform: `scale(0.96)`

### 3.3 Recent Activity Card

**Layout:** Vertical list with recent items

**Item Structure:**
```css
.recent-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px;
    border-radius: 8px;
    background: var(--bg-secondary);
}
```

**Icon Container:**
- Size: 36x36px
- Border radius: 8px
- Background: `var(--bg)`
- Border: 1px solid `var(--border)`

**Content:**
- Title: 14px, 500 weight
- Time: 11px, tertiary text color

---

## 4. Discover Page - Tab System

### 4.1 Tab Bar Structure

```css
.tab-bar {
    display: flex;
    gap: 8px;
    margin-bottom: 20px;
    padding-bottom: 0;
    border-bottom: 1px solid var(--border-light);
}
```

**Four Tabs:**
1. **翻译** (Translation) - Default active
2. **测验** (Quiz)
3. **对话** (Chat)
4. **指令** (Commands)

### 4.2 Tab Button Styling

```css
.tab-btn {
    padding: 10px 16px;
    background: transparent;
    border: none;
    color: var(--text-secondary);
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.15s ease;
    position: relative;
}
```

**Active State:**
```css
.tab-btn.active {
    color: var(--text);
}

.tab-btn.active::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: var(--text);
}
```

**Inactive State:**
- Color: `var(--text-secondary)`
- Hover color: `var(--text)`

**Indicator:**
- 2px solid bottom border
- Color: `var(--text)`
- Spans full width of button

### 4.3 Tab Content Switching

```css
.tab-content {
    display: none;
}

.tab-content.active {
    display: block;
    animation: fadeIn 0.2s ease-out;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(4px); }
    to { opacity: 1; transform: translateY(0); }
}
```

---

## 5. Tab Content Details

### 5.1 Translation Tab

**Language Selector:**
```css
.lang-selector {
    display: flex;
    gap: 8px;
    margin: 16px 0;
}
```

**Three Language Options:**
- 中文 (Chinese) - Default active
- English
- 日本語 (Japanese)

**Language Button Styling:**
```css
.lang-btn {
    flex: 1;
    padding: 10px;
    border-radius: 8px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    color: var(--text);
    font-size: 13px;
    font-weight: 500;
}
```

**Input Area:**
```css
.translate-input {
    width: 100%;
    padding: 14px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    color: var(--text);
    font-size: 15px;
    resize: none;
    margin-bottom: 12px;
}
```

**Translation Result:**
```css
.translate-result {
    margin: 12px 0;
    padding: 14px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
}
```

**Result Header:**
- Language label (uppercase, 11px)
- Copy button (24x24px)

**Result Text:**
- Font size: 15px
- Line height: 1.5

**Translate Button:**
```css
.translate-btn {
    width: 100%;
    padding: 14px;
    border-radius: 10px;
    background: var(--accent);
    color: var(--accent-text);
    font-size: 15px;
    font-weight: 500;
    border: none;
}
```

### 5.2 Quiz Tab

**Configuration Bar:**
```css
.quiz-config-bar {
    display: flex;
    gap: 12px;
    align-items: center;
    margin-bottom: 16px;
}
```

**Category Selector:**
- Dropdown with options: 英语, 日语, 德语
- Styling: 10px border radius, bg-secondary background

**Mode Pills:**
```css
.quiz-mode-pills {
    flex: 1;
    display: flex;
    gap: 6px;
}
```

**Three Modes:**
1. **选择题** (Multiple Choice)
2. **对话** (Conversation)
3. **通话** (Voice Call)

**Pill Styling:**
```css
.quiz-mode-pill {
    flex: 1;
    padding: 10px 12px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    color: var(--text-secondary);
    font-size: 12px;
    font-weight: 500;
}
```

**Question Card:**
- Number: "第 1 题" (12px, secondary color)
- Difficulty badge: "中级" (11px, rounded)
- Question text: 15px, line-height 1.5

**Options:**
```css
.quiz-options {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.quiz-option {
    padding: 12px 14px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    color: var(--text);
    font-size: 14px;
    text-align: left;
}
```

**Voice Call Interface:**
```css
.voice-call-container {
    text-align: center;
    padding: 20px 0;
}
```

**Avatar:**
- Size: 64x64px
- Circle shape
- Mic icon inside
- Border: 1px solid `var(--border)`

**Status:**
- Name: 15px, 500 weight
- State: 13px, secondary color

**Wave Animation:**
- 5 bars, 3px wide each
- Animated height scaling
- Gap: 3px between bars

**Control Buttons:**
- Mute: 48x48px circle
- Call button: 56x56px (larger)
- Speaker: 48x48px circle
- Gap: 16px between buttons

### 5.3 Chat Tab

**Chat Bubbles:**
```css
.chat-bubble {
    max-width: 85%;
    padding: 12px 14px;
    border-radius: 12px;
    font-size: 14px;
    line-height: 1.5;
    margin-bottom: 8px;
}
```

**AI Bubble:**
```css
.chat-bubble.ai {
    background: var(--bg-secondary);
    color: var(--text);
    border-bottom-left-radius: 4px;
}
```

**User Bubble:**
```css
.chat-bubble.user {
    background: var(--accent);
    color: var(--accent-text);
    border-bottom-right-radius: 4px;
    margin-left: auto;
}
```

**Input Area:**
```css
.ai-input-wrapper {
    display: flex;
    gap: 8px;
    margin-top: 12px;
}

.ai-input {
    flex: 1;
    padding: 12px 14px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    color: var(--text);
    font-size: 14px;
}

.ai-send-btn {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: var(--accent);
    color: var(--accent-text);
}
```

**Note:** Deep thinking toggle is NOT present in the chat tab in this prototype version.

### 5.4 Commands Tab

**Command Suggestions:**
```css
.commands-suggestions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 20px;
}
```

**Command Chips:**
```css
.command-chip {
    padding: 8px 14px;
    border-radius: 20px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    color: var(--text-secondary);
    font-size: 12px;
}
```

**Suggestions:**
- "开始英语测验"
- "翻译"你好"到英语"
- "制定学习计划"

**Active Tasks Panel:**
```css
.commands-tasks-panel {
    padding: 14px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    margin-bottom: 16px;
}
```

**Task Item:**
- Name: 14px, 500 weight
- Current step: 12px, secondary color
- Progress bar: 4px height
- Progress percentage: 11px

**Command History:**
```css
.commands-history {
    margin-bottom: 16px;
}

.command-entry {
    padding: 14px 0;
    border-bottom: 1px solid var(--border-light);
}
```

**Entry Structure:**
- Input command (mono-style, 14px)
- Output with dot indicator
- Output text (13px, secondary color)

**Command Input:**
```css
.commands-input-wrapper {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
}

.commands-prompt {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--text);
}

.commands-input {
    flex: 1;
    border: none;
    background: transparent;
    font-size: 14px;
}

.commands-send-btn {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    background: var(--accent);
    color: var(--accent-text);
}
```

---

## 6. Profile Page

### 6.1 Profile Header Card

```css
.profile-header {
    text-align: center;
    padding: 24px 0;
}
```

**Avatar:**
- Size: 72x72px
- Circle shape
- User icon inside
- Border: 1px solid `var(--border)`

**User Info:**
- Name: 20px, 500 weight
- Bio: 13px, secondary color

### 6.2 Settings Sections

**Section Title:**
```css
.settings-section-title {
    font-size: 12px;
    font-weight: 500;
    color: var(--text-tertiary);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin-bottom: 12px;
    padding-left: 4px;
}
```

### 6.3 AI Settings Section

**Settings Item:**
```css
.settings-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 16px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 10px;
    margin-bottom: 8px;
}
```

**Settings Icon:**
- Size: 32x32px
- Border radius: 8px
- Background: `var(--bg-secondary)`
- Border: 1px solid `var(--border)`
- SVG icon: 18x18px

**AI Settings Items:**
1. **AI 模型** - Dropdown selector
2. **AI 增强翻译** - Toggle switch (active)
3. **智能推荐** - Toggle switch (active)
4. **语音助手** - Toggle switch (inactive)
5. **深度思考模式** - Toggle switch (inactive)

**Toggle Switch:**
```css
.toggle-switch {
    width: 44px;
    height: 24px;
    border-radius: 12px;
    background: var(--border);
    position: relative;
    cursor: pointer;
    transition: background 0.2s ease;
}

.toggle-switch.active {
    background: var(--accent);
}

.toggle-switch::after {
    content: '';
    position: absolute;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: var(--bg);
    top: 2px;
    left: 2px;
    transition: transform 0.2s ease;
}

.toggle-switch.active::after {
    transform: translateX(20px);
    background: var(--accent-text);
}
```

### 6.4 App Settings Section

**Theme Selector (Inline):**
```css
.theme-selector-inline {
    display: flex;
    gap: 6px;
}
```

**Theme Buttons:**
```css
.theme-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 12px;
    border-radius: 8px;
    background: var(--bg-secondary);
    border: 1px solid var(--border);
    color: var(--text-secondary);
    font-size: 12px;
}
```

**Options:**
1. **浅色** (Light) - Sun icon, active
2. **深色** (Dark) - Moon icon

### 6.5 Other Section

**Items:**
1. **个人信息** (Personal Info) - User icon
2. **隐私与安全** (Privacy & Security) - Shield icon
3. **关于 Tiz** (About) - Info icon

**Arrow Indicator:**
- Right pointing arrow: "›"
- Color: `var(--text-tertiary)`
- Size: 18px

---

## 7. Notification System

### 7.1 Notification Badge

```css
.notification-badge {
    position: absolute;
    top: -2px;
    right: -2px;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    background: var(--text);
    color: var(--bg);
    font-size: 10px;
    font-weight: 500;
    display: flex;
    align-items: center;
    justify-content: center;
}
```

**Location:** Top-right corner of notification button
**Content:** Number of unread notifications

### 7.2 Notification Panel

```css
.notification-panel {
    position: fixed;
    top: 60px;
    right: 16px;
    width: 280px;
    max-height: 400px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 12px;
    z-index: 1000;
    opacity: 0;
    visibility: hidden;
    transform: translateY(-8px);
    transition: all 0.2s ease;
    overflow: hidden;
}
```

**Show State:**
```css
.notification-panel.show {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}
```

**Note:** No shadow on panel (pure flat design)

### 7.3 Panel Structure

**Header:**
```css
.notification-header {
    padding: 14px 16px;
    border-bottom: 1px solid var(--border-light);
    display: flex;
    justify-content: space-between;
    align-items: center;
}
```

- Title: "通知" (14px, 500 weight)
- Close button: 24x24px, rounded 6px

**List:**
```css
.notification-list {
    max-height: 300px;
    overflow-y: auto;
    padding: 8px;
}
```

### 7.4 Notification Item

```css
.notification-item {
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 6px;
    cursor: pointer;
    transition: background 0.15s ease;
}
```

**Unread State:**
```css
.notification-item.unread {
    background: var(--bg-secondary);
}
```

**Item Header:**
- Dot indicator: 6px circle, `var(--text)`
- Title: 13px, 500 weight
- Time: 11px, tertiary color

**Item Body:**
- Font size: 12px
- Color: `var(--text-secondary)`
- Line height: 1.4

**Sample Notifications:**
1. "AI 翻译完成" - "您的文档翻译已完成"
2. "新功能上线" - "AI 增强翻译模式现已可用"

---

## 8. Interaction Details

### 8.1 Border Radius Values

- Cards: 12px
- Buttons: 8-10px
- Inputs: 10px
- Quick action buttons: 10px
- Command chips: 20px (fully rounded)
- Toggle switch: 12px
- Small elements: 6-8px

### 8.2 Spacing System

**Card Padding:** 20px
**Card Margin:** 12px
**Button Padding:** 10-14px
**Input Padding:** 12-14px
**Gap between elements:** 8-16px

**4px Grid Based:**
- Base unit: 4px
- Common gaps: 8px (2 units), 12px (3 units), 16px (4 units)

### 8.3 Transition Animations

**Duration:** 0.15-0.2s
**Easing:** ease / ease-out

**Page Transition:**
```css
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(4px); }
    to { opacity: 1; transform: translateY(0); }
}
```

**Hover Effects:**
- Border color change
- Background color change for buttons
- No scale on hover (scale only on active)

**Active States:**
- Transform: `scale(0.96)` to `scale(0.98)`
- Quick, subtle feedback

### 8.4 Borders & Dividers

**Standard Border:**
```css
border: 1px solid var(--border);
```

**Light Border:**
```css
border: 1px solid var(--border-light);
```

**Bottom Border for Tab Bar:**
```css
border-bottom: 1px solid var(--border-light);
```

**NO Shadows** - Pure flat design throughout

### 8.5 Focus States

**Input Focus:**
```css
.translate-input:focus {
    outline: none;
    border-color: var(--text-tertiary);
}
```

**Button Hover:**
```css
.icon-btn:hover {
    background: var(--border-light);
}
```

---

## 9. SVG Icons

### 9.1 Icon Specifications

**Stroke Width:** 1.5 or 2
**Fill:** none
**Stroke:** currentColor

### 9.2 Icon List

**Bottom Navigation:**
1. **Home Icon:** House shape with door
2. **Compass Icon:** Circle with diamond needle
3. **Profile Icon:** User silhouette (head + shoulders)

**Quick Actions:**
1. **Translation Icon:** Language characters (A, 文)
2. **Quiz Icon:** Question mark in circle
3. **Chat Icon:** Speech bubble

**Notification:**
- **Bell Icon:** Bell shape with small clapper

**Translation Tab:**
- **Copy Icon:** Two overlapping rectangles

**Quiz Tab:**
- **Mic Icon:** Microphone for voice call
- **Phone Icon:** Handset for call button
- **Mute Icon:** Microphone with line through
- **Speaker Icon:** Speaker with sound waves

**Chat Tab:**
- **Send Icon:** Paper airplane

**Commands Tab:**
- **Send Icon:** Paper airplane (smaller, 16px)

**Profile Page:**
- **AI Model Icon:** Microphone
- **Translation Icon:** Language characters
- **Compass Icon:** For smart recommendations
- **Mic Icon:** For voice assistant
- **Question Icon:** For deep thinking mode
- **Sun Icon:** For light theme
- **Moon Icon:** For dark theme
- **User Icon:** For personal info
- **Shield Icon:** For privacy
- **Info Icon:** For about

---

## 10. JavaScript Functionality

### 10.1 Theme Switching

**Storage:** localStorage with key 'tiz-theme'
**Default:** Light theme
**Application:** Sets `data-theme` attribute on documentElement

**Theme Buttons:**
- Light: Sun icon + "浅色" label
- Dark: Moon icon + "深色" label

### 10.2 Tab Switching

**Discover Page Tabs:**
- Four tabs: translate, quiz, chat, commands
- Active class toggling
- Content display/hide
- fadeIn animation on content switch

**Navigation Tabs:**
- Three pages: home, discover, profile
- Active state management
- Page visibility toggling

### 10.3 Language Selection

**Translation Tab:**
- Three language buttons
- Active state toggling
- Visual feedback on selection

### 10.4 Quiz Interactions

**Option Selection:**
- Click to select (adds 'selected' class)
- 200ms delay
- Auto-marks as correct (adds 'correct' class)
- Visual feedback throughout

### 10.5 Voice Call Control

**Call Button:**
- Toggles between call and hangup states
- Changes icon (phone → handset)
- Shows/hides wave animation
- Updates status text

**States:**
- Idle: "点击开始通话"
- Active: "通话中..."

### 10.6 Toggle Switches

**All Toggles:**
- Click to toggle active class
- Visual state change
- No value persistence shown in prototype

### 10.7 Notification System

**Panel Toggle:**
- Click notification button to show
- Click close button to hide
- Click outside to hide
- Event propagation stopped on button click

**Notification Items:**
- Click to mark as read
- Removes 'unread' class
- Removes dot indicator
- Updates badge count
- Hides badge when no unread

**Badge Update:**
- Count unread items
- Update number or hide badge

### 10.8 Command Input

**Send Command:**
- Get input value
- Create new command entry
- Add to history (insert at top)
- Show thinking animation
- Clear input
- Simulate AI response after delay

**Command Entry Structure:**
```html
<div class="command-entry processing">
    <div class="command-input">> [command text]</div>
    <div class="command-output">
        <span class="command-thinking"></span>
        <span class="command-output-text">AI 正在分析指令...</span>
    </div>
</div>
```

**Response Simulation:**
- 1.5 second delay
- Responses based on command keywords
- Removes 'processing' class
- Shows actual result

---

## Summary of Key Design Patterns

### Color Usage
- **Minimalist palette:** Only essential colors
- **Gray scale hierarchy:** Primary, secondary, tertiary text
- **Accent color:** Same as primary text (high contrast)
- **No gradients:** Solid colors only

### Typography
- **Clear hierarchy:** Size and weight establish importance
- **Display font:** Source Serif 4 for headings
- **Body font:** Inter for UI text
- **Letter spacing:** -0.02em on large headings

### Spacing
- **Generous padding:** More breathing room than typical
- **Consistent gaps:** 4px grid system
- **Card margins:** 12px between cards

### Borders & Shapes
- **Consistent radius:** 10-12px for most elements
- **Thin borders:** 1px throughout
- **No shadows:** Pure flat design

### Animations
- **Fast transitions:** 0.15-0.2s standard
- **Subtle effects:** Border color, small scale changes
- **Purposeful motion:** Only for state changes

### Icons
- **SVG only:** No emoji or bitmap icons
- **Consistent stroke:** 1.5-2px width
- **Monoline style:** Clean, modern look

---

## Implementation Notes for Flutter

### Theme Configuration
- Create ThemeData matching exact color values
- Implement theme persistence with shared_preferences
- Support for both light and dark themes

### Custom Widgets Needed
1. TabBar with bottom border indicator
2. ToggleSwitch component
3. NotificationPanel with slide animation
4. CommandChip with rounded corners
5. ChatBubble with different styles
6. VoiceCallInterface with wave animation
7. QuickActionGrid button
8. SettingsItem with icon and toggle/dropdown

### State Management
- Provider for theme switching
- Provider for notification state
- Provider for command history
- Provider for quiz state

### Animation Timing
- Page transitions: 200ms
- Hover effects: 150ms
- Scale on active: 150ms
- Use Curves.easeOut for most animations

### Text Styles
- Create TextStyles matching exact sizes and weights
- Implement letter spacing for headings
- Use Inter font family

### Border Radius
- Create constants for consistent radius values
- Use BorderRadius.circular() with exact values

### Navigation
- Bottom navigation bar with 3 tabs
- Page-based navigation (not nested routes)
- Preserve state when switching tabs

---

**Document Version:** 1.0
**Last Updated:** 2026-02-08
**Analyst:** Claude Code
