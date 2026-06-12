---
name: CTAE/MPUAT seminar report format
description: College of Technology and Engineering (Udaipur) B.Tech seminar report layout — colours, structure, prelim/body conventions
type: reference
originSessionId: 41adc402-ae58-4978-a160-4b216ed4d238
---
# CTAE Udaipur seminar report layout

Reference: `~/Downloads/XAI_Shraddha-1.pdf` (Shraddha Mehra, Explainable AI, B.Tech AI&DS 2025–26)
Mirror build: `~/Downloads/World_Models_Seminar_Build/seminar.html` + `World_Models_Vishal_Tank.pdf`

## Brand
- College name (top): bold serif, navy `#19366A`
- University line: bold serif, green `#2F7C44`
- "UDAIPUR (RAJ.)": bold black
- Topic title on cover: bold serif, maroon `#7E2D3F`
- "Submitted By:" header: maroon
- CTAE seal: 781×694 PNG from `upload.wikimedia.org/wikipedia/commons/8/8e/College_of_Technology_%26_Engineering%2C_Udaipur.png` (download with browser UA)

## Required prelim sections (in order)
1. Cover (no page #)
2. Acknowledgement (no #) — gratitude to HOD by name, then department, friends/classmates, parents
3. Declaration (no #) — "I hereby declare that the seminar report titled <b>"TOPIC"</b> has been developed by me…"
4. Table of Contents (no #)
5. List of Figures (page i, lower-roman starts here)
6. List of Tables (ii)
7. Abbreviations (iii)
8. Abstract (page 1, arabic starts here)

## Body sections
- 7 chapters typical: Introduction, Foundations, Architectures/Methods, Training, Applications, Evaluation/Challenges, Summary+Conclusion
- Each chapter starts on a new page with "CHAPTER N — TITLE" centred bold
- Subsections "N.1 Title" left-aligned bold
- IEEE-format references at end

## Typography
- Times New Roman (or Liberation Serif), 12pt body
- Justified text, ~1.5 line height
- Captions: bold 11pt centred, "Figure N — Caption." / "Table N — Caption."
- A4, 1" margins on all sides

## Page numbering (Chrome print quirk)
Chrome's `--print-to-pdf` ignores `counter-reset`/`counter-set` on named @page rules. Practical workaround: render once, extract actual page positions with pypdf, then update TOC TDs to match. See `feedback_chrome_print_counter_reset.md`.

## Render command
```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="OUTPUT.pdf" --print-to-pdf-no-header \
  --virtual-time-budget=10000 \
  "file:///path/to/seminar.html"
```
