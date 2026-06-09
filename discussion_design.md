# Design Discussion: Showcase Cards & Homepage Polish

Here is a comprehensive list of ideas to elevate the homepage from "good" to "WOW!". Read through these proposals and share your preferences so we can implement them together.

---

## 1. Color Combination & Glassmorphism
The current card has a hard dark gradient overlay at the bottom. This looks like a dark patch on a light screen.

### Proposed Solution: Frosted Glassmorphism (Glassmorphic Adaptive Panel)
Instead of a simple container, we will use a **`BackdropFilter` (frosted glass)** effect with a thin border and theme-adaptive colors.
* **Light Mode:**
  * **Background:** Semi-transparent white (`white.withOpacity(0.55)`) with a blur of `10.0`.
  * **Border:** A very thin light border (`white.withOpacity(0.4)`) to catch the light.
  * **Text colors:**
    * Category Label: **Luxury Bronze/Gold** (e.g., `#B76E79` or `#C5A880`)
    * Title: **Deep Navy** (e.g., `#0F172A`)
    * Description: **Muted Slate** (e.g., `#475569`)
* **Dark Mode:**
  * **Background:** Semi-transparent midnight navy/black (`black.withOpacity(0.55)`) with a blur of `10.0`.
  * **Border:** A thin dark border (`white.withOpacity(0.08)`).
  * **Text colors:**
    * Category Label: **Accent Gold** (e.g., `#D4AF37`)
    * Title: **Soft White** (e.g., `#FFFFFF`)
    * Description: **Muted Silver** (e.g., `#94A3B8`)

---

## 2. Typography & Fonts
Currently, the landing page uses `Ubuntu` and `Playfair Display`. To make the cards feel high-end and luxury:
* **Proposed Fonts:**
  * **Card Titles:** `Cormorant Garamond` (a serif font designed specifically for editorial and luxury branding, with elegant curves and high contrast).
  * **Card Labels & Descriptions:** `Outfit` or `Inter` (a clean, modern geometric sans-serif font).
  * **App Text Base:** We will pre-load and cache these fonts in `_TemplateFontCache` to keep the scroll perfectly smooth.

---

## 3. Card Size & Grid Layout
5 columns on desktop makes cards narrow and makes details hard to read.
* **Proposed Change:** Reduce columns on desktop from **5 to 4**.
  * This automatically increases card size by **~20%**, giving the invitation designs the prominence they deserve.
  * Adjust title font sizes to be larger and more readable.

---

## 4. Hover Micro-Animations & Glow Effects
* **Golden Gradient Border:** Instead of a solid flat yellow border on hover, we will draw a **shining golden gradient border** (fading from gold to light gold) using a custom painter.
* **Animated Glow/Shadow:** On hover, the card's shadow will smoothly expand and gain a subtle colored glow (a soft gold glow in dark/light modes) matching the card theme.
* **Button Transition:** The "Use This Theme" button will fade and slide up from the bottom of the card smoothly.

---

## 5. Sliding Tab Selector (A Major "WOW!" Element)
Currently, filtering templates (clicking "All", "Royal", etc.) snaps instantly.
* **Proposed Change:** Implement a **sliding pill indicator** behind the active tab. When you tap "Royal" or "Luxury", the blue/gold active pill background will **slide smoothly** to the new tab, mimicking high-end web app transitions.

---

## User Discussion & Feedback
Please check these options and select your favorites:

### Your Notes & Selections:
* **Frosted Glass Panel:** [Yes / No]
* **Luxury Fonts (Cormorant Garamond + Outfit):** [Yes / No]
* **4-Column Desktop Grid (larger cards):** [Yes / No]
* **Golden Gradient Border & Glow on Hover:** [Yes / No]
* **Sliding Tab Selector:** [Yes / No]
