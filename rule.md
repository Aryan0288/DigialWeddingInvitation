# Project Rules

## 1. Architecture Rules

* Always follow the MVVM (Model-View-ViewModel) architecture.
* Keep business logic inside ViewModels.
* Views should contain only UI-related code.
* Models should only represent data structures and domain entities.
* Maintain proper separation of concerns.

## 2. Clarification Rule (Mandatory)

Before starting any implementation:

* Analyze the requirement carefully.
* If any requirement is unclear, ask questions first.
* Do not make assumptions for critical functionality.
* Wait for clarification before implementation when needed.

## 3. Context Documentation Rule

After completing any implementation:

### IMPORTANT

* Update `CONTEXT.md`.
* Never modify, rewrite, remove, or replace existing entries.
* Never regenerate the entire file.
* Only append new information at the bottom.

Example:

## Existing Context

Feature A implemented
Feature B implemented

## New Update

Feature C implemented
API X integrated
Bug Y fixed

## 4. Change Tracking

For every implementation, document:

* Feature added
* Files created
* Files modified
* Architectural decisions
* Important assumptions
* Dependencies added or removed

## 5. Code Quality Rules

* Write clean and maintainable code.
* Follow SOLID principles where applicable.
* Avoid code duplication.
* Keep methods focused on a single responsibility.
* Use meaningful naming conventions.

## 6. Safety Rules

* Do not delete existing functionality unless explicitly requested.
* Do not refactor unrelated code.
* Do not change project structure without approval.
* Preserve backward compatibility whenever possible.

## 7. Implementation Workflow

1. Read the requirement.
2. Review existing project context.
3. Ask clarifying questions if needed.
4. Create implementation plan.
5. Implement following MVVM.
6. Verify changes.
7. Append implementation details to `CONTEXT.md`.
8. Provide summary of changes.

## 8. Response Format

For every task:

* Requirement Understanding
* Questions (if any)
* Implementation Plan
* Code Changes
* context.md Append Section
* Final Summary

# Additional Design Rules

## IMPORTANT

The primary goal of this project is to improve the visual quality and premium feel of the Wedding Invitation Builder.

When suggesting improvements:

### Focus On

* Better wedding card designs
* Better landing page design
* Better color combinations
* Better typography
* Better user experience
* Better template previews
* Better animations
* Better responsive layouts
* Better premium feel

---

## Do NOT Suggest

Unless explicitly requested:

* Removing Firebase
* Replacing Firestore
* Replacing Hive
* Replacing BroadcastChannel
* Replacing MVVM
* Replacing existing project architecture
* Large-scale backend rewrites
* Changing the RSVP flow

The current architecture should be respected.

Suggestions should focus mainly on UI, UX, design quality, template quality, and user experience.

---

## Template Design Rules

Current templates should be enhanced and expanded.

Always suggest new premium templates.

Example categories:

### Royal Collection

* Maharaja Palace
* Rajputana Gold
* Royal Peacock
* Mughal Heritage

### Luxury Collection

* Ivory Gold
* Champagne Gold
* Emerald Royal
* Midnight Navy

### Floral Collection

* Rose Garden
* Lavender Bloom
* White Magnolia
* Cherry Blossom

### Modern Collection

* Minimal Gold
* Elegant Serif
* Contemporary Wedding
* Luxury Black & Gold

---

## Theme Suggestions

When proposing templates:

Provide:

* Theme Name
* Color Palette
* Typography
* Layout Style
* Decorative Elements
* Preview Description

Do not only change colors.

Each template should have a unique visual identity.

---

## Landing Page Improvements

Always suggest:

* Modern hero section
* Premium wedding imagery
* Better CTA design
* Elegant color palettes
* Modern card previews
* Template showcase section
* Feature highlights
* Better spacing and typography

Landing page should feel like a premium SaaS product.

---

## Color Palette Rules

Prefer premium combinations such as:

### Ivory Luxury

Background: #F8F5F0
Primary: #1F1F1F
Accent: #C8A96A

### Royal Navy

Background: #0D1B2A
Primary: #FFFFFF
Accent: #D4AF37

### Emerald Royal

Background: #0F3D3E
Primary: #F7F4EA
Accent: #D4AF37

### Rose Gold

Background: #FFF5F5
Primary: #6B4F4F
Accent: #B76E79

### Black Gold

Background: #121212
Primary: #FFFFFF
Accent: #D4AF37

---

## Design Goal

The final product should resemble a premium wedding invitation platform and provide multiple elegant design options that users would be proud to share with their guests.

Whenever design improvements are requested, prioritize aesthetics, premium feel, modern UI, and variety of invitation templates over architectural changes.

