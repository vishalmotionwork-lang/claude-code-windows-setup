---
name: feedback_no_bottom_sheets
description: DaduOS uses nested pages for project/task detail, NOT bottom sheets. Status shown on card only, not repeated in detail.
type: feedback
---

When building DaduOS navigation:
- Project/task detail opens as a **full nested page** with back arrow, NOT a slide-up bottom sheet
- Status is already shown on the project card (top right badge) — do NOT show a status flow/progress bar again on the detail page
- Create flow adapts per content type — carousel/reel_cover don't need hook variant count
- Stack-based navigation: push project → push task → back pops

**Why:** User explicitly said "I need it to have a new nested page and so on and so forth" and "we are showing the status already on the project on top right, we dont need to show the second page"

**How to apply:** Any time opening a detail view in DaduOS, use pushProject/pushTask from useNavigation, never BottomSheet. Keep BottomSheet only for create flows and quick actions.
