---
name: reference_jsxbin_decompile
description: How to decompile an After Effects / ExtendScript .jsxbin back to readable .jsx on macOS
metadata: 
  node_type: memory
  type: reference
  originSessionId: 8e25bebe-563b-496e-a4b8-023ce82b86cc
---

`.jsxbin` files (After Effects / Photoshop / ExtendScript panels) are compiled bytecode — header `@JSXBIN@ES@2.0@`. They CAN be decompiled to readable, editable `.jsx` source. Free closed-source scripts are fair to decompile for personal features — see [[feedback_dont_refuse_pursue_technical_path]].

**Working setup (macOS, done 2026-06-04):**
- Decompiler: `codecopy/jsxbin-to-jsx-converter` (GitHub). C# / .NET Framework 4.5, ~3,400 LOC of pure decoder in `jsxbin_to_jsx/JsxbinDecoding/*.cs`. The `Jsbeautifier.dll` dependency is Windows-only but is ONLY used for output formatting in `Program.cs` — the decoder itself has no Windows deps, so drop it.
- macOS has no .NET → `brew install dotnet` (installs .NET 10).
- Port to modern dotnet: copy `JsxbinDecoding/` into a fresh console project, write a tiny `Program.cs` that calls `AbstractNode.Decode(jsxbinString, false)` and writes the result (skip the beautifier). `.csproj` with `<TargetFramework>net10.0</TargetFramework>` (match the installed runtime — net8 fails if only net10 present), `OutputType=Exe`, `ImplicitUsings=disable`, `Nullable=disable`.
- `dotnet build -c Release` then `dotnet bin/Release/net10.0/<name>.dll input.jsxbin output.jsx`.
- Decoded a 4.5KB panel to clean, readable source in seconds. Output quality was excellent — real function names, structure intact.

**Gotcha — decompiled IIFEs:** decoder emits anonymous functions as `function (x) {...}(this)` which is invalid as a statement. Wrap them: `(function (x) {...})(this)`. Same for inner `function(i,row){...}(i,currentRow)` → wrap in parens.

**Run edited source without recompiling:** AE runs plain `.jsx` panels fine. Just place the edited `.jsx` (with its `presets/` + `icons/` folders) in the ScriptUI Panels folder, or `File > Scripts > Run Script File…` for a floating palette. No need to re-compile back to `.jsxbin`. (npm `jsxbin` package only does jsx→jsxbin if you ever need to.)
