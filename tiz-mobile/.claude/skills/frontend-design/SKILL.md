---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt
---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

## Design Thinking for Tiz

**Tiz Project Default: Minimalist Design**

This project follows **minimalist design principles**. Always default to this aesthetic unless the user explicitly requests otherwise:

### Core Principles
1. **Restraint** - Only essential elements, no decoration for decoration's sake
2. **Generous Whitespace** - 20-30% more padding than standard designs
3. **Clear Hierarchy** - Font size and weight establish importance, not color
4. **Consistent Details** - Unified 10-12px border radius, 1px borders
5. **Fast Transitions** - All animations 0.15-0.2s for responsiveness
6. **Functional Color** - Colors indicate state, not decoration

### Typography
- **Display Font**: Source Serif 4 (headings, 32px, -0.02em letter-spacing)
- **Body Font**: Inter (UI text, 13-16px)
- NEVER use generic fonts like Arial or system fonts as primary choices
- Pair distinctive display font with refined body font

### Color System
```css
/* Light Theme */
--bg: #ffffff
--bg-secondary: #f9fafb
--text: #111827
--text-secondary: #6b7280
--text-tertiary: #9ca3af
--border: #e5e7eb
--accent: #111827

/* Dark Theme */
--bg: #0a0a0a
--bg-secondary: #141414
--text: #fafafa
--text-secondary: #a1a1aa
--text-tertiary: #71717a
--border: #262626
--accent: #fafafa
```

### Spacing & Sizing
- Card padding: 20px
- Card margin: 12px minimum
- Button padding: 10-14px
- Input padding: 12-14px
- Corner radius: 10-12px for most elements
- Border width: 1px

### Animation
- Duration: 0.15-0.2s
- Easing: ease / ease-out
- Page transitions: 0.2s fade + 4px slide
- Hover: Border color change only
- Active: Scale 0.96-0.98

### What to AVOID
- ❌ Gradient backgrounds
- ❌ Decorative emojis
- ❌ Excessive shadows or glows
- ❌ Rounded corners > 16px
- ❌ Slow animations (> 0.3s)
- ❌ Multiple accent colors
- ❌ Glassmorphism or blur effects
- ❌ Decorative illustrations
- ❌ Unnecessary badges or labels
- ❌ Purple gradients on white backgrounds

## Alternative Aesthetics

If user explicitly requests a different style, consider these directions:
- Brutally minimal (even more restrained)
- Editorial/magazine (bold typography, asymmetric layouts)
- Soft/pastel (gentle colors, rounded forms)
- Industrial/utilitarian (raw, functional, data-dense)

**CRITICAL**: Choose a clear direction and execute with precision. Intentionality matters more than intensity.

## Implementation Guidelines

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

**IMPORTANT**: Match implementation complexity to the aesthetic vision. Minimalist designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.
