---
name: Figma plugin sandbox gotchas
description: Three reproducible gotchas when building Figma plugins from scratch — figjam editorType, QuickJS ES2020 syntax, dynamic-page documentAccess + sync vector API. Apply on every new plugin scaffold.
type: feedback
originSessionId: e118d353-c816-4b98-8aa9-71e6d2a2e7b9
---
When scaffolding a new Figma plugin from scratch, three errors WILL appear in this exact order if not preempted. All three were hit during the KnowAI Iso & Shapes build (2026-04-30). Set up the manifest + tsconfig correctly the first time so they don't surface.

## 1. `Manifest error: Expected manifest.containsWidget to have type true`

**Trigger:** `editorType: ["figma","figjam"]` in manifest.json.

**Why:** FigJam treats third-party additions as widgets, not plugins. Including "figjam" in editorType requires `containsWidget: true`. Adding that converts your plugin to a widget (different API, different lifecycle).

**How to apply:** If your plugin is a UI iframe (not a widget), use `editorType: ["figma"]` only. Drop FigJam unless you specifically want widget mode.

## 2. `Syntax error on line N: Unexpected token ?`

**Trigger:** tsconfig `"target": "es2020"` (or higher). Source code uses `??` (nullish coalescing).

**Why:** Figma's plugin runtime is QuickJS, which doesn't support `??`. With target es2020, TypeScript preserves `??` instead of transpiling it. The error appears in `vendor-core-...js` (Figma's bundled JS), not your source — misleading.

**How to apply:** Set tsconfig `"target": "es2017"` and `"lib": ["es2017"]`. TypeScript will transpile `??` to `(a !== null && a !== void 0 ? a : b)`. Same applies to other ES2020+ syntax: optional chaining `?.`, `globalThis`, etc.

## 3. `Cannot call set_vectorNetwork with documentAccess: dynamic-page. Use setVectorNetworkAsync instead.`

**Trigger:** manifest has `"documentAccess": "dynamic-page"` AND code uses sync setters like `node.vectorNetwork = X`.

**Why:** Figma's newer publishing model requires dynamic-page access (it's mandatory in the publish flow for new plugins). In dynamic-page mode, the entire scene graph is lazily loaded, so sync writes to nodes that may not be loaded yet are forbidden. All such APIs have async counterparts.

**How to apply:** From the start, write all vector creation as `await node.setVectorNetworkAsync({...})`. Same for `setVectorPathsAsync`, `setSharedPluginDataAsync`, etc. Make all wrapping functions `async` returning `Promise<...>`. The compiler will catch missing awaits if you do this consistently.

**Bonus:** Manifest changes (NOT code changes) require re-importing the plugin — Figma hot-reload only watches `dist/code.js`. If a manifest edit "doesn't take effect", remove + re-import the plugin from manifest.

## Source of truth

Full gotchas table + fixes documented at:
`~/.claude/projects/-Users-vishal-motion/memory/projects/knowai-figma-plugins/CONTEXT.md`
