---
name: Implement Articles Detail Page
description: Implementation of a new dedicated page for reading full articles, maintaining the premium design system.
type: project
---

# Context
The user wants to move from the landing page to a dedicated "Articles" page where users can read the full content of the articles featured on the home page. This requires a new HTML page and potential additions to the CSS/JS to maintain elegance and simplicity.

# Implementation Plan

## 1. "Artigos" Detail Page (`artigo.html`)
- **Goal**: Create a high-end, readable page for full article content.
- **UI Design**:
    - **Header**: Reuse the existing header component from `index.html` for consistency.
    - **Hero/Header Section**: A clean, impactful area featuring the article title, category tag, and a high-quality featured image.
    - **Content Area**: A focused, single-column layout optimized for reading (typography-centric).
    - **Typography**: Use the existing "Inter" font with generous line height and appropriate font sizes for readability.
    - **Sidebar/Context (Optional)**: A subtle area for "Related Articles" or "Author Info" to increase engagement, or keep it purely minimalist.
    - **Footer**: Reuse the existing footer component from `index.html`.
- **Components to Reuse**:
    - `header` (from `index.html`)
    - `footer` (from `index.html`)
    - Design system tokens (colors, shadows, spacing) from `src/input.css`.

## 2. CSS Enhancements (`src/input.css`)
- **Goal**: Add styles specific to the article reading experience.
- **New Components**:
    - `.article-detail-container`: For managing the reading width (max-width optimized for reading).
    - `.article-content-body`: Specific typography styles for long-form text (prose-like styling: margins between paragraphs, styling for headings, lists, etc.).
    - `.article-meta`: Styling for the date, author, and category tag within the article page.

## 3. JavaScript Integration (`script.js`)
- **Goal**: Ensure the responsive menu and other interactive elements work on the new page.
- **Task**: Verify/Ensure `script.js` is properly linked and functional on `artigo.html`.

## Files to Create/Modify
- `artigo.html` (New file)
- `src/input.css` (To add article-specific typography and layout styles)
- `script.js` (Check for compatibility)

## Verification
- **Visual Check**: Verify the page looks premium, follows the design system (white space, soft shadows, typography), and is fully responsive.
- **Navigation Check**: Ensure the header and footer links work and that the user can return to the home page.
- **Readability Check**: Confirm text is easy to read on both desktop and mobile.
