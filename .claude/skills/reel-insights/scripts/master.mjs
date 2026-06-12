#!/usr/bin/env node
// master.mjs — build MASTER.md for the CURRENT project: everything-in-one-place
// context for Meta AI / A-B comparison / brainstorming. Multi-window aware.
//   node <skill>/scripts/master.mjs    →   writes ./MASTER.md
import { readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { join } from "node:path";

const ROOT = process.env.REEL_PROJECT || process.cwd();
const REELS_DIR = join(ROOT, "reels");
if (!existsSync(REELS_DIR)) { console.error("No reels/ in", ROOT); process.exit(1); }

const WINDOWS = ["1h", "24h", "48h", "weekly", "lifetime"];
const WLABEL = { "1h": "1h", "24h": "24h", "48h": "48h", "weekly": "Week", "lifetime": "Life" };

const reels = readdirSync(REELS_DIR, { withFileTypes: true })
  .filter((d) => d.isDirectory() && existsSync(join(REELS_DIR, d.name, "data.json")))
  .map((d) => {
    const r = JSON.parse(readFileSync(join(REELS_DIR, d.name, "data.json"), "utf8"));
    const tp = join(REELS_DIR, d.name, (r.files && r.files.transcript) || "transcript.txt");
    r._script = existsSync(tp) ? readFileSync(tp, "utf8").trim() : "";
    return r;
  })
  .sort((a, b) => (a.rank || 99) - (b.rank || 99));
if (!reels.length) { console.error("No reels."); process.exit(1); }

const n = (v) => (v == null ? "—" : String(v).replace(/\B(?=(\d{3})+(?!\d))/g, ","));
const pct = (v) => (v == null ? "—" : v + "%");
const sec = (v) => (v == null ? "—" : v + "s");
const present = (r) => WINDOWS.filter((w) => r.windows && r.windows[w]);
const latest = (r) => { const w = present(r); return w.length ? r.windows[w[w.length - 1]] : {}; };
const metric = (r, key) => (latest(r)[key]);

let cfg = {};
try { cfg = JSON.parse(readFileSync(join(ROOT, "reels.config.json"), "utf8")); } catch {}
const handle = cfg.handle || "@zeeeljain";

const lead = (label, key, fmt, best = "max") => {
  const valid = reels.filter((r) => metric(r, key) != null);
  if (!valid.length) return null;
  const s = [...valid].sort((a, b) => best === "max" ? metric(b, key) - metric(a, key) : metric(a, key) - metric(b, key));
  return `- **${label}:** ${s[0].title} — ${fmt(metric(s[0], key))}`;
};
const wins = [
  lead("Most views", "views", n), lead("Best hold — highest avg watch", "avgWatchSec", sec),
  lead("Best hook — lowest skip", "skipRate", pct, "min"), lead("Most saves", "saves", n),
  lead("Most comments", "comments", n), lead("Most shares", "shares", n), lead("Most follows", "follows", n),
].filter(Boolean);

const today = new Date().toISOString().slice(0, 10);
let md = `# ${handle} — Reel A/B Master Context\n`;
md += `_Generated ${today} · ${reels.length} reels · metric of record = **views** · source = IG Reel Insights_\n\n`;
md += `Single hand-off doc: every reel's transcript + full performance across capture windows\n(1h / 24h / 48h / weekly / lifetime). Feed it to Meta AI for better scripts, compare what won, scope the next A/B test.\n\n`;

md += `## Leaderboard (by latest views)\n\n`;
md += `| Rank | Type | Reel | Views | Reached | Avg watch | Skip | Saves | Comments | Follows |\n`;
md += `|---:|:--:|------|------:|--------:|----------:|-----:|------:|---------:|--------:|\n`;
for (const r of reels) {
  const tag = r.postType === "trial" ? "🔴 Trial" : r.postType === "feed" ? "🔵 Feed" : "—";
  md += `| ${r.rank} | ${tag} | ${r.title} | ${n(metric(r, "views"))} | ${n(metric(r, "reached"))} | ${sec(metric(r, "avgWatchSec"))} | ${pct(metric(r, "skipRate"))} | ${n(metric(r, "saves"))} | ${n(metric(r, "comments"))} | ${n(metric(r, "follows"))} |\n`;
}
md += `\n## What won (auto-computed, latest window)\n\n${wins.join("\n")}\n\n`;

md += `## Per-reel dossiers\n\n`;
for (const r of reels) {
  const dir = `reels/${r.id}`;
  const w = present(r);
  md += `### #${r.rank} · ${r.title} — ${n(metric(r, "views"))} views ${r.postType ? "(" + r.postType + ")" : ""}\n\n`;
  md += `- **URL:** ${r.url} · **CTA:** ${r.cta} · **Length:** ${sec(r.videoLengthSec)}\n`;
  md += `- **Hook:** “${r.hook}”\n`;
  md += `- **Files:** \`${dir}/reel.mp4\` · \`${dir}/insights/\` · \`${dir}/transcript.txt\`\n`;
  md += `- **Board nodes:** reel ${r.nodes?.reelVideo || "—"} · insights ${r.nodes?.insightsVideo || "—"} · link ${r.nodes?.link || "—"}\n\n`;
  if (w.length) {
    const rows = [["Views", "views", n], ["Reached", "reached", n], ["Avg watch", "avgWatchSec", sec], ["Skip", "skipRate", pct], ["Follows", "follows", n], ["Likes", "likes", n], ["Comments", "comments", n], ["Shares", "shares", n], ["Saves", "saves", n]];
    md += `  | Metric | ${w.map((x) => WLABEL[x]).join(" | ")} |\n  |---|${w.map(() => "--:").join("|")}|\n`;
    for (const [label, key, fmt] of rows) {
      if (w.every((x) => r.windows[x][key] == null)) continue;
      md += `  | ${label} | ${w.map((x) => fmt(r.windows[x][key])).join(" | ")} |\n`;
    }
    md += `\n`;
  }
  const st = r.stable || {}, d = st.discovery || {}, a = st.audience || {};
  const src = [["Feed", d.feed], ["Reels tab", d.reelsTab], ["Profile", d.profile], ["Explore", d.explore], ["Stories", d.stories]].filter((s) => s[1] != null).map((s) => `${s[0]} ${s[1]}%`).join(" · ");
  const ages = [["18-24", a["18-24"]], ["25-34", a["25-34"]], ["35-44", a["35-44"]]].filter((s) => s[1] != null).map((s) => `${s[0]} ${s[1]}%`).join(" · ");
  if (src) md += `  - **Discovery:** ${src}\n`;
  if (ages) md += `  - **Audience:** ${ages}${a.languages ? " · langs: " + a.languages : ""}\n`;
  md += `\n  **Script:**\n\n  > ${r._script.replace(/\n+/g, " ").trim()}\n\n`;
}

const topWin = wins[0] ? wins[0].replace("- **Most views:** ", "") : "";
md += `## Hand-off prompt for Meta AI (paste this + this doc)\n\n\`\`\`\n`;
md += `You are a short-form scriptwriter for ${handle} (AI educator, India, Hindi-first 18-34 audience).\n`;
md += `Below are ${reels.length} past reels with FULL transcripts and real performance across time windows\n(1h/24h/48h/weekly/lifetime). Metric of record = VIEWS.\n\n`;
md += `1. What do the top performers share — hook, structure, CTA, topic, pacing — vs the bottom?\n`;
md += `2. Winner this batch: ${topWin}. Reverse-engineer WHY from the retention + saves + comments signals.\n`;
md += `3. Compare Trial vs Main-feed posts (the Type column) — does one format consistently out-perform?\n`;
md += `4. Look at the 1h→24h→48h growth: which reels had strong first-hour velocity? That's the early hit signal.\n`;
md += `5. Write 3 new reel scripts on a topic I give you, using ONLY the patterns that correlated with high views.\n   Each: a 3-second hook, tight body, comment-trigger CTA (the lowest performer had no voiced CTA).\n\n`;
md += `Do NOT invent metrics — only use the numbers in this doc.\n\`\`\`\n\n`;
md += `> Meta AI is reliable on what you HAND it (this doc) and fabricates on what you ask it to FETCH.\n> Always paste the text; never ask it to pull a reel by link or read Insights. (See meta-ai-scripting-workflows.)\n`;

writeFileSync(join(ROOT, "MASTER.md"), md);
console.log("✓ wrote MASTER.md  (" + reels.length + " reels)  winner:", topWin || "n/a");
