---
name: Figma plugin + Gumroad license monetization pattern
description: How paid Figma plugins work — free Community listing gated by Gumroad license-key API. Reusable model if KnowAI ever wants to monetize a plugin.
type: reference
originSessionId: ac05f58b-1fa5-4e77-8824-eb2dce3cd314
---
# Figma Plugin + Gumroad License — Monetization Pattern

## The model

Figma Community has **no built-in monetization** — all plugins are free to install. Devs work around this by publishing the plugin free, then gating features behind a license check that calls Gumroad's free License API.

## Real-world example

[Ren Yi's bundle on Gumroad](https://renyi6199.gumroad.com/l/myhfg) — Fast Isometric + Isometric Studio + Shapes plugins, $30 one-time, 556 sales = ~$16.7K lifetime, 5★ rating from 8 verified buyers.

## Flow

```
User buys product on Gumroad
  ↓
Gumroad emails license key (auto, free feature)
  ↓
User installs free plugin from Figma Community
  ↓
Plugin opens → "Enter License Key" UI (figma.showUI)
  ↓
User pastes key → plugin POSTs to Gumroad License API:
    POST https://api.gumroad.com/v2/licenses/verify
    body: { product_permalink: "myhfg", license_key: "..." }
  ↓
Gumroad returns { success: true, purchase: {...}, uses: N }
  ↓
Plugin stores activation in figma.clientStorage
  ↓
Plugin runs unlocked — license check skipped on subsequent runs
```

## Implementation (~50 lines of TS)

```typescript
// In Figma plugin code.ts
const PRODUCT_ID = "myhfg";

async function verifyLicense(key: string): Promise<boolean> {
  const res = await fetch("https://api.gumroad.com/v2/licenses/verify", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `product_permalink=${PRODUCT_ID}&license_key=${encodeURIComponent(key)}`,
  });
  const data = await res.json();
  if (data.success) {
    await figma.clientStorage.setAsync("license_key", key);
    return true;
  }
  return false;
}

// On plugin start:
const stored = await figma.clientStorage.getAsync("license_key");
if (!stored) figma.showUI(__html__);   // show entry form
else runUnlocked();
```

Manifest needs `networkAccess: { allowedDomains: ["https://api.gumroad.com"] }`.

## Why it's clever

- **Zero backend infrastructure** — Gumroad handles payments, tax, refunds, license uniqueness, even seat counts
- **Free Community distribution** — huge organic discovery via Figma's plugin search
- **One-time purchase** feels low-friction vs subscription
- **Refund handling** is built-in (Gumroad invalidates the key)
- **Trial flow** is just a try-before-buy free version of the plugin

## When to apply for KnowAI

If we ever want to monetize a Figma plugin idea:
1. Build the plugin in TypeScript
2. Publish free to Figma Community (review takes ~3-7 days)
3. Set up Gumroad product with "Generate license key per sale" toggle ON
4. Add the license-verify call to the plugin (50 lines)
5. Promote: Twitter, r/FigmaDesign, Producthunt, KnowAI's own audience

Same model works for any tool with a UI shell — Sketch plugins, VS Code extensions, Photoshop scripts, AE plugins (Caelix could use this), Chrome extensions.

## Internal-use shortcut

If you don't want to sell — skip everything Gumroad. Just build the plugin and load via `Plugins → Development → Import plugin from manifest…` in Figma desktop. That's what we did for `knowai-figma-plugins/`.
