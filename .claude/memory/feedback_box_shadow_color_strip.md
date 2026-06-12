---
name: css-shadow-regex-strip-colors-first
description: Parsing box-shadow / filter:drop-shadow numbers — strip color literals (rgb, rgba, hsl, hex, named) BEFORE extracting numbers. Otherwise digits inside rgba(...) get matched as offset/blur/spread.
type: feedback
originSessionId: 584b889f-1a76-423c-80b4-c19cbd446ba1
---
When parsing CSS `box-shadow` or `filter: drop-shadow(...)` to compute visual expansion, **strip color literals before extracting numbers**. Otherwise the parser treats digits inside `rgba(0, 0, 0, 0.5)` as shadow offsets / blur / spread.

**Why:** Built element-png-capture (May 2026). My regex `/-?\d+(?:\.\d+)?(?=px|\s|,|$)/g` matches `0`, `0`, `0`, `0.5` from `rgba(0,0,0,0.5)`. CSS allows the color to come *before* the offset values:
- Canonical: `0 4px 12px rgba(0,0,0,0.5)` → first 4 numbers are correct (0, 4, 12, _)
- Color-first: `rgba(0,0,0,0.5) 0 4px 12px` → my regex picks up `0, 0, 0, 0.5` as offset/blur/spread → reports 0.5 px expansion when actual is 12 px blur. Capture comes out cropped.
- Worse: `box-shadow: 0 0 200px rgba(0,0,0,0.05)` — 200 px ambient blur — without color stripping the parser correctly reads it, but the visual-rect code uses it for expansion → over-expanded clip.

**How to apply:**

```js
function parseBoxShadowExpansion(boxShadow) {
  if (!boxShadow || boxShadow === "none") return 0;
  const parts = splitTopLevelCommas(boxShadow);  // separate multiple shadows
  let maxEx = 0;
  for (const part of parts) {
    let s = part.trim();
    if (/^inset\b/i.test(s)) continue;             // inset shadows don't expand outside
    // Strip color tokens FIRST
    s = s.replace(/rgba?\([^)]+\)/g, " ");
    s = s.replace(/hsla?\([^)]+\)/g, " ");
    s = s.replace(/#[0-9a-fA-F]{3,8}/g, " ");
    s = s.replace(/\b(transparent|currentColor|inherit|initial|unset|none)\b/gi, " ");
    // Now numbers in `s` are only offset / blur / spread
    const nums = s.match(/-?\d+(?:\.\d+)?/g) || [];
    if (nums.length < 2) continue;
    const ox = Math.abs(parseFloat(nums[0]) || 0);
    const oy = Math.abs(parseFloat(nums[1]) || 0);
    const blur = nums.length > 2 ? Math.abs(parseFloat(nums[2]) || 0) : 0;
    const spread = nums.length > 3 ? Math.abs(parseFloat(nums[3]) || 0) : 0;
    const both = Math.max(ox, oy) + blur + spread;
    if (both > maxEx) maxEx = both;
  }
  return Math.ceil(maxEx);
}

function splitTopLevelCommas(s) {
  const out = []; let depth = 0, start = 0;
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (c === "(") depth++;
    else if (c === ")") depth--;
    else if (c === "," && depth === 0) { out.push(s.slice(start, i)); start = i + 1; }
  }
  out.push(s.slice(start));
  return out;
}
```

**Test cases that distinguish correct from broken parser:**
- `0 4px 12px rgba(0,0,0,0.5)` → 12 px expansion ✅
- `rgba(0,0,0,0.5) 0 4px 12px` → 12 px expansion (broken parser: 0.5 px)
- `0 0 200px rgba(0,0,0,0.05)` → 200 px expansion
- `0 4px 12px rgba(0,0,0,0.5), 0 8px 24px rgba(0,0,0,0.2)` → max 24 px expansion (multi-shadow)
- `inset 0 1px 2px rgba(0,0,0,0.05)` → 0 expansion (inset doesn't extend outside)

**Same fix applies to `filter: drop-shadow(...)`** — strip the color portion inside the drop-shadow() arg before extracting numbers.
