// ============================================================================
//  reel-insights — FigJam doc builder (MULTI-WINDOW, columns). data-in → section-out.
//  Each reel → one named SECTION + a doc whose time-varying metrics are a TABLE
//  (rows × time-window columns: 1h / 24h / 48h / weekly / lifetime). Stable metrics
//  (discovery, audience, rates) show once. All Figma gotchas baked in (see reference/WORKFLOW.md).
//
//  Injected by prep.mjs above this file:  const REELS=[...]; const SCRIPTS={id:"…"}; const CTX={…};
//  Ends with `return await run();` — figma_execute wraps it in an async context.
// ============================================================================
const WINDOW_ORDER = ["1h", "24h", "48h", "weekly", "lifetime"];
const WINDOW_LABEL = {
  "1h": "1H",
  "24h": "24H",
  "48h": "48H",
  weekly: "WEEK",
  lifetime: "LIFE",
};
// post-type tag, pinned top-right of the section (user answers feed-vs-trial at paste time)
const POST_TAG = {
  trial: { label: "Trials", bg: { r: 0.91, g: 0.318, b: 0.176 } }, // #E8512D red-orange (matches reference)
  feed: { label: "Main feed", bg: { r: 0.078, g: 0.427, b: 0.969 } }, // #146DF7 brand blue
};

const T = {
  ink: { r: 0.02, g: 0.071, b: 0.106 },
  grey: { r: 0.42, g: 0.467, b: 0.521 },
  green: { r: 0.106, g: 0.561, b: 0.353 },
  blue: { r: 0.078, g: 0.427, b: 0.969 },
  white: { r: 1, g: 1, b: 1 },
  hair: { r: 0.901, g: 0.913, b: 0.933 },
};
const F = {
  label: { family: "Roboto Mono", style: "Medium" },
  num: { family: "Inter", style: "Bold" },
  semi: { family: "Inter", style: "Semi Bold" },
  body: { family: "Inter", style: "Regular" },
};
const W = 600,
  PAD = 34,
  INNER = W - PAD * 2; // 532 usable

async function loadFonts() {
  for (const f of Object.values(F)) await figma.loadFontAsync(f);
}
function solid(c) {
  return [{ type: "SOLID", color: c }];
}
// pull a local video via the patched bridge UI (main thread has no network) → bytes
function fetchVideoBytes(url) {
  return new Promise((resolve, reject) => {
    const rid = "v_" + Math.floor(Math.random() * 1e9);
    const h = (m) => {
      if (m && m.type === "FETCH_VIDEO_RESULT" && m.requestId === rid) {
        figma.ui.off("message", h);
        m.error ? reject(new Error(m.error)) : resolve(m.bytes);
      }
    };
    figma.ui.on("message", h);
    setTimeout(() => {
      figma.ui.off("message", h);
      reject(new Error("video fetch timeout: " + url));
    }, 25000);
    figma.ui.postMessage({ type: "FETCH_VIDEO", url, requestId: rid });
  });
}
async function videoRect(url, w, h2, name) {
  const v = await figma.createVideoAsync(await fetchVideoBytes(url));
  const r = figma.createRectangle();
  r.resize(w, h2);
  r.cornerRadius = 12;
  r.name = name;
  r.fills = [{ type: "VIDEO", scaleMode: "FILL", videoHash: v.hash }];
  return r;
}
function txt(chars, font, size, color, o) {
  o = o || {};
  const t = figma.createText();
  t.fontName = font;
  t.fontSize = size;
  t.characters = String(chars);
  t.fills = solid(color);
  if (o.spacing != null)
    t.letterSpacing = { value: o.spacing, unit: "PERCENT" };
  if (o.line != null) t.lineHeight = { value: o.line, unit: "PERCENT" };
  if (o.align) t.textAlignHorizontal = o.align;
  if (o.width != null) {
    t.textAutoResize = "HEIGHT";
    t.resize(o.width, t.height);
  } else t.textAutoResize = "WIDTH_AND_HEIGHT";
  return t;
}
function vstack(name, spacing, fill) {
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = "VERTICAL";
  f.itemSpacing = spacing;
  f.fills = fill || [];
  f.primaryAxisSizingMode = "AUTO";
  f.counterAxisSizingMode = "AUTO";
  return f;
}
function hstack(name, spacing) {
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = "HORIZONTAL";
  f.itemSpacing = spacing;
  f.fills = [];
  f.primaryAxisSizingMode = "AUTO";
  f.counterAxisSizingMode = "AUTO";
  return f;
}
function chip(label, value, accent, size) {
  const f = vstack("c:" + label, 5);
  f.appendChild(
    txt(String(label).toUpperCase(), F.label, 9, T.grey, { spacing: 4 }),
  );
  f.appendChild(txt(value, F.num, size || 20, accent || T.ink));
  return f;
}
function chipGroup(heading, chips) {
  if (!chips.length) return null;
  const g = vstack("g:" + heading, 14);
  g.layoutAlign = "STRETCH";
  g.counterAxisSizingMode = "FIXED";
  g.appendChild(
    txt(String(heading).toUpperCase(), F.label, 10, T.green, { spacing: 6 }),
  );
  const row = figma.createFrame();
  row.name = "row";
  row.layoutMode = "HORIZONTAL";
  row.layoutWrap = "WRAP";
  row.itemSpacing = 28;
  row.counterAxisSpacing = 18;
  row.fills = [];
  row.layoutAlign = "STRETCH";
  row.primaryAxisSizingMode = "FIXED";
  row.counterAxisSizingMode = "AUTO";
  for (const c of chips) row.appendChild(c);
  g.appendChild(row);
  return g;
}
function hairline(w) {
  const l = figma.createRectangle();
  l.name = "hr";
  l.resize(w || INNER, 1);
  l.fills = solid(T.hair);
  l.layoutAlign = "STRETCH";
  return l;
}

const n = (v) =>
  v == null ? "—" : String(v).replace(/\B(?=(\d{3})+(?!\d))/g, ","); // manual commas (no Intl in sandbox)
const pct = (v) => (v == null ? "—" : v + "%");
const sec = (v) => (v == null ? "—" : v + "s");

// ---- the time-window table -------------------------------------------------
// rows = metrics, columns = present windows. Skips a row if all windows are null.
const TABLE_ROWS = [
  ["Views", "views", n],
  ["Reached", "reached", n],
  ["Avg watch", "avgWatchSec", sec],
  ["Skip rate", "skipRate", pct],
  ["Retention end", "retentionEndPct", pct],
  ["Follows", "follows", n],
  ["Likes", "likes", n],
  ["Comments", "comments", n],
  ["Shares", "shares", n],
  ["Saves", "saves", n],
  ["Reposts", "reposts", n],
  ["Profile visits", "profileVisits", n],
  ["Bio link taps", "bioTaps", n],
];
function buildTable(r, windows) {
  const labelW = 150;
  const gap = 10;
  const valW = Math.max(
    64,
    Math.floor((INNER - labelW - gap * windows.length) / windows.length),
  );
  const tbl = vstack("metrics-table", 11);
  tbl.layoutAlign = "STRETCH";
  tbl.counterAxisSizingMode = "FIXED";

  // header row
  const head = hstack("thead", gap);
  head.layoutAlign = "STRETCH";
  head.primaryAxisSizingMode = "FIXED";
  head.appendChild(
    txt("METRIC", F.label, 9, T.grey, { spacing: 4, width: labelW }),
  );
  for (const w of windows)
    head.appendChild(
      txt(
        WINDOW_LABEL[w] || w.toUpperCase(),
        F.label,
        9,
        w === "lifetime" ? T.green : T.grey,
        { spacing: 3, width: valW, align: "RIGHT" },
      ),
    );
  tbl.appendChild(head);
  tbl.appendChild(hairline());

  for (const [label, key, fmt] of TABLE_ROWS) {
    const present = windows.map((w) =>
      r.windows[w] ? r.windows[w][key] : null,
    );
    if (present.every((v) => v == null)) continue;
    const row = hstack("tr:" + key, gap);
    row.layoutAlign = "STRETCH";
    row.primaryAxisSizingMode = "FIXED";
    row.counterAxisAlignItems = "CENTER";
    row.appendChild(txt(label, F.label, 11, T.grey, { width: labelW }));
    present.forEach((v, i) => {
      const isLast = windows[i] === "lifetime";
      row.appendChild(
        txt(fmt(v), F.num, 17, v == null ? T.hair : isLast ? T.ink : T.ink, {
          width: valW,
          align: "RIGHT",
        }),
      );
    });
    tbl.appendChild(row);
  }
  return tbl;
}

// ---- doc frame --------------------------------------------------------------
function latestWindow(r) {
  for (let i = WINDOW_ORDER.length - 1; i >= 0; i--)
    if (r.windows[WINDOW_ORDER[i]]) return r.windows[WINDOW_ORDER[i]];
  return {};
}
function buildDoc(r) {
  const windows = WINDOW_ORDER.filter((w) => r.windows && r.windows[w]);
  const last = latestWindow(r);
  const stable = r.stable || {};

  const doc = figma.createFrame();
  doc.name = "ABdoc_" + r.id;
  doc.resize(W, 200);
  doc.layoutMode = "VERTICAL";
  doc.itemSpacing = 22;
  doc.paddingLeft = doc.paddingRight = doc.paddingTop = doc.paddingBottom = PAD;
  doc.fills = solid(T.white);
  doc.cornerRadius = 18;
  doc.primaryAxisSizingMode = "AUTO";
  doc.counterAxisSizingMode = "FIXED";

  // header
  const head = hstack("ABhead_" + r.id, 12);
  head.counterAxisAlignItems = "CENTER";
  head.layoutAlign = "STRETCH";
  head.primaryAxisSizingMode = "FIXED";
  const av = figma.createEllipse();
  av.name = "ABavatar_" + r.id;
  av.resize(46, 46);
  av.fills = CTX.avatarHash
    ? [{ type: "IMAGE", scaleMode: "FILL", imageHash: CTX.avatarHash }]
    : solid(T.hair);
  head.appendChild(av);
  const idf = vstack("id", 2);
  idf.layoutGrow = 1;
  idf.appendChild(txt(CTX.handle || "@zeeeljain", F.semi, 15, T.ink));
  idf.appendChild(
    txt((CTX.followers || "126K") + " FOLLOWERS", F.label, 9, T.grey, {
      spacing: 2,
    }),
  );
  head.appendChild(idf);
  const pill = hstack("pill", 0);
  pill.paddingLeft = pill.paddingRight = 13;
  pill.paddingTop = pill.paddingBottom = 6;
  pill.cornerRadius = 20;
  pill.fills = solid(r.rank === 1 ? T.green : T.ink);
  pill.appendChild(txt("#" + r.rank, F.num, 12, T.white));
  head.appendChild(pill);
  doc.appendChild(head);

  // title
  doc.appendChild(txt(r.title, F.num, 28, T.ink, { width: INNER, line: 110 }));

  // meta + hook
  const meta = vstack("meta", 14);
  meta.layoutAlign = "STRETCH";
  meta.counterAxisSizingMode = "FIXED";
  const mrow = hstack("mrow", 36);
  mrow.appendChild(chip("Reel posted", r.postedDate || "—", T.ink, 13));
  mrow.appendChild(
    chip(
      "Windows",
      windows.map((w) => WINDOW_LABEL[w]).join(" · ") || "—",
      T.ink,
      13,
    ),
  );
  mrow.appendChild(chip("CTA", r.cta || "—", T.blue, 13));
  meta.appendChild(mrow);
  const hk = vstack("hook", 6);
  hk.layoutAlign = "STRETCH";
  hk.counterAxisSizingMode = "FIXED";
  hk.appendChild(txt("HOOK", F.label, 9, T.grey, { spacing: 4 }));
  hk.appendChild(
    txt("“" + r.hook + "”", F.semi, 14, T.ink, { width: INNER, line: 140 }),
  );
  meta.appendChild(hk);
  doc.appendChild(meta);

  doc.appendChild(hairline());

  // PERFORMANCE OVER TIME (the table)
  const perf = vstack("g:Performance", 12);
  perf.layoutAlign = "STRETCH";
  perf.counterAxisSizingMode = "FIXED";
  perf.appendChild(
    txt("PERFORMANCE OVER TIME", F.label, 10, T.green, { spacing: 6 }),
  );
  perf.appendChild(buildTable(r, windows.length ? windows : ["lifetime"]));
  doc.appendChild(perf);

  // RATES (single — from latest window)
  doc.appendChild(
    chipGroup(
      "Rates (latest)",
      [
        last.commentRate != null
          ? chip("Comment rate", pct(last.commentRate))
          : null,
        last.saveRate != null ? chip("Save rate", pct(last.saveRate)) : null,
        last.shareRate != null ? chip("Share rate", pct(last.shareRate)) : null,
        last.likeRate != null ? chip("Like rate", pct(last.likeRate)) : null,
      ].filter(Boolean),
    ) || vstack("noop", 0),
  );

  // DISCOVERY (stable)
  const d = stable.discovery || {};
  const srcs = [
    ["Feed", d.feed],
    ["Reels tab", d.reelsTab],
    ["Profile", d.profile],
    ["Explore", d.explore],
    ["Stories", d.stories],
    ["Search", d.search],
  ]
    .filter((s) => s[1] != null)
    .map((s) => chip(s[0], pct(s[1])));
  const dg = chipGroup("Discovery — top sources", srcs);
  if (dg) doc.appendChild(dg);

  // AUDIENCE (stable)
  const a = stable.audience || {};
  const ages = [
    ["13-17", a["13-17"]],
    ["18-24", a["18-24"]],
    ["25-34", a["25-34"]],
    ["35-44", a["35-44"]],
    ["45-54", a["45-54"]],
  ]
    .filter((s) => s[1] != null)
    .map((s) => chip(s[0], pct(s[1])));
  const aud = chipGroup("Audience age", ages);
  if (aud && a.languages) {
    const lang = vstack("lang", 5);
    lang.layoutAlign = "STRETCH";
    lang.counterAxisSizingMode = "FIXED";
    lang.appendChild(txt("TOP LANGUAGES", F.label, 9, T.grey, { spacing: 4 }));
    lang.appendChild(txt(a.languages, F.semi, 13, T.ink, { width: INNER }));
    aud.appendChild(lang);
  }
  if (aud) doc.appendChild(aud);

  // SCRIPT
  const script =
    typeof SCRIPTS !== "undefined" && SCRIPTS ? SCRIPTS[r.id] : null;
  if (script) {
    doc.appendChild(hairline());
    const sg = vstack("g:Script", 10);
    sg.layoutAlign = "STRETCH";
    sg.counterAxisSizingMode = "FIXED";
    sg.appendChild(txt("SCRIPT", F.label, 10, T.green, { spacing: 6 }));
    sg.appendChild(
      txt(String(script).trim(), F.body, 12, T.ink, {
        width: INNER,
        line: 150,
      }),
    );
    doc.appendChild(sg);
  }
  doc.appendChild(
    txt(
      "Source: Instagram Reel Insights · metric of record = views · columns = capture windows",
      F.label,
      8,
      T.grey,
      { spacing: 3 },
    ),
  );
  return doc;
}

// post-type tag pill, pinned top-right of the section
function buildTag(postType) {
  const cfg = POST_TAG[postType];
  if (!cfg) return null;
  const pill = hstack("ABtag_" + postType, 0);
  pill.paddingLeft = pill.paddingRight = 16;
  pill.paddingTop = pill.paddingBottom = 9;
  pill.cornerRadius = 8;
  pill.fills = solid(cfg.bg);
  pill.appendChild(txt(cfg.label, F.semi, 14, T.white));
  return pill;
}

// ---- section assembly + runner ---------------------------------------------
// Layout matches the reference: link (top-left) + post-type tag (top-right) band,
// reel + insights videos below it, the metrics doc below that. Tag is ALWAYS top-right.
async function buildReelSection(r) {
  const lifeViews = (
    (r.windows &&
      (r.windows.lifetime ||
        r.windows.weekly ||
        r.windows["48h"] ||
        r.windows["24h"] ||
        r.windows["1h"])) ||
    {}
  ).views;
  const M = 40; // section inner margin
  const secW = M + W + M; // doc is widest → 680
  const s = figma.createSection();
  s.name = "#" + r.rank + " · " + r.title + " · " + n(lifeViews) + " views";
  s.fills = solid(T.white);
  s.resizeWithoutConstraints(secW, 1000);
  const out = {
    id: r.id,
    section: s.id,
    doc: null,
    movedReel: false,
    movedInsights: false,
  };

  // top band: link (left) + tag (right)
  let bandBottom = M;
  let linkNode = null;
  if (CTX.moveVideos && r.nodes && r.nodes.link) {
    linkNode = await figma.getNodeByIdAsync(r.nodes.link);
    if (linkNode) {
      s.appendChild(linkNode);
      linkNode.x = M;
      linkNode.y = M;
      bandBottom = Math.max(bandBottom, M + (linkNode.height || 90));
    }
  }
  const tag = buildTag(r.postType);
  if (tag) {
    s.appendChild(tag);
    tag.x = secW - tag.width - M;
    tag.y = M;
  }

  // videos row (below the band)
  let docY = tag || linkNode ? M + 64 : M; // leave room for the tag/link band
  if (CTX.moveVideos && r.nodes) {
    let vy = linkNode ? bandBottom + 16 : M + 64;
    let vx = M;
    let vBottom = null;
    if (r.nodes.reelVideo) {
      const v = await figma.getNodeByIdAsync(r.nodes.reelVideo);
      if (v) {
        s.appendChild(v);
        v.x = vx;
        v.y = vy;
        try {
          v.resize(203, 360);
        } catch (e) {}
        vx += 203 + 14;
        vBottom = vy + 360;
        out.movedReel = true;
      }
    }
    if (r.nodes.insightsVideo) {
      const v = await figma.getNodeByIdAsync(r.nodes.insightsVideo);
      if (v) {
        s.appendChild(v);
        v.x = vx;
        v.y = vy;
        try {
          v.resize(166, 360);
        } catch (e) {}
        vBottom = vy + 360;
        out.movedInsights = true;
      }
    }
    docY = vBottom ? vBottom + 30 : bandBottom + 24;
  }

  // videos from the local CORS server, created via createVideoAsync (fully automatic).
  // Needs CTX.videoBaseUrl (e.g. http://localhost:9232) + the patched FETCH_VIDEO handler.
  if (CTX.videoBaseUrl && !out.movedReel) {
    let vy = linkNode ? bandBottom + 16 : M + 64;
    let vx = M,
      vBottom = null;
    try {
      const rr = await videoRect(
        CTX.videoBaseUrl + "/" + r.id + "/reel.mp4",
        203,
        360,
        "ABreel_" + r.id,
      );
      s.appendChild(rr);
      rr.x = vx;
      rr.y = vy;
      vx += 203 + 14;
      vBottom = vy + 360;
      out.reelVideo = true;
    } catch (e) {
      out.reelVideoErr = String((e && e.message) || e).slice(0, 80);
    }
    const presentW = WINDOW_ORDER.filter((w) => r.windows && r.windows[w]);
    const lastKey = presentW.length ? presentW[presentW.length - 1] : null;
    if (lastKey) {
      try {
        const ir = await videoRect(
          CTX.videoBaseUrl + "/" + r.id + "/insights/" + lastKey + ".mp4",
          166,
          360,
          "ABins_" + r.id,
        );
        s.appendChild(ir);
        ir.x = vx;
        ir.y = vy;
        vBottom = vy + 360;
        out.insVideo = true;
      } catch (e) {
        /* no insights recording for that window (e.g. screenshot) — skip silently */
      }
    }
    if (vBottom) docY = vBottom + 30;
  }

  // doc
  const doc = buildDoc(r);
  s.appendChild(doc);
  doc.x = M;
  doc.y = docY;
  out.doc = doc.id;
  if (tag) {
    tag.x = secW - tag.width - M;
    tag.y = M;
  } // re-pin after width settles

  s.resizeWithoutConstraints(secW, docY + doc.height + M);
  return { section: s, out };
}
async function run() {
  await loadFonts();
  await figma.loadAllPagesAsync();
  const made = [];
  let y = CTX.originY != null ? CTX.originY : 4200;
  const x = CTX.originX != null ? CTX.originX : 0;
  for (const r of REELS) {
    const { section, out } = await buildReelSection(r);
    section.x = x;
    section.y = y;
    y += section.height + (CTX.rowGap || 160);
    made.push(out);
  }
  if (made.length)
    figma.viewport.scrollAndZoomIntoView([
      await figma.getNodeByIdAsync(made[0].section),
    ]);
  return made;
}
return await run();
