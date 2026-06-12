#!/usr/bin/env node
// stub-data.mjs — write a per-reel data.json stub (MULTI-WINDOW schema) into the
// current project. hook auto-fills from transcript.txt first sentence if present.
//   node .../stub-data.mjs <id> <url> [--rank N] [--title ".."] [--cta ".."] [--windows 1h,24h,48h,weekly,lifetime]
import { readFileSync, writeFileSync, existsSync, readdirSync } from "node:fs";
import { join } from "node:path";

const ROOT = process.env.REEL_PROJECT || process.cwd();
const [id, url] = process.argv.slice(2);
if (!id) { console.error("usage: stub-data.mjs <id> <url> [--rank N] [--title ..] [--cta ..] [--windows ..]"); process.exit(1); }
const arg = (k) => { const i = process.argv.indexOf("--" + k); return i >= 0 ? process.argv[i + 1] : null; };

const dir = join(ROOT, "reels", id);
const tp = join(dir, "transcript.txt");
let hook = "";
if (existsSync(tp)) { const t = readFileSync(tp, "utf8").trim().replace(/\s+/g, " "); hook = (t.split(/(?<=[.!?])\s/)[0] || t).slice(0, 180); }
const existing = existsSync(join(ROOT, "reels")) ? readdirSync(join(ROOT, "reels")).filter((d) => existsSync(join(ROOT, "reels", d, "data.json"))).length : 0;

const windowKeys = (arg("windows") || "lifetime").split(",").map((s) => s.trim()).filter(Boolean);
const blankWindow = () => ({ views: null, reached: null, avgWatchSec: null, skipRate: null, retentionEndPct: null, follows: null, likes: null, comments: null, shares: null, saves: null, reposts: null, commentRate: null, saveRate: null, shareRate: null, likeRate: null, profileVisits: null, bioTaps: null });
const windows = {}; for (const w of windowKeys) windows[w] = blankWindow();

const postType = (arg("type") || "").toLowerCase().startsWith("f") ? "feed" : (arg("type") ? "trial" : "");
const data = {
  id, rank: arg("rank") ? Number(arg("rank")) : existing + 1,
  title: arg("title") || "", topic: "", url: url || `https://www.instagram.com/p/${id}/`,
  postType, // "trial" | "feed" — user answers when pasting the reel
  postedDate: "", cta: arg("cta") || "", hook, videoLengthSec: null,
  stable: { retentionStartPct: null, discovery: { reelsTab: null, feed: null, explore: null, profile: null, stories: null, search: null }, audience: { "13-17": null, "18-24": null, "25-34": null, "35-44": null, "45-54": null, languages: "" } },
  windows,
  nodes: { reelVideo: "", insightsVideo: "", link: "" },
  files: { reel: "reel.mp4", transcript: "transcript.txt", caption: "caption.txt", insights: "insights/" },
};
writeFileSync(join(dir, "data.json"), JSON.stringify(data, null, 2) + "\n");
console.log("✓ data.json stub for", id, "— windows:", windowKeys.join(", "), "(fill metrics from each window's Insights)");
