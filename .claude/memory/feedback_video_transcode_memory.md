---
name: Video transcode memory budget
description: Single-invocation ffmpeg HLS ladders OOM past ~3 parallel x264 encodes on 8GB Docker VMs — cap the ladder or run tiers serially
type: feedback
originSessionId: ca87d7de-a494-4067-8b2c-66c695d1e7ce
---
When building HLS adaptive-bitrate ladders via one ffmpeg call with `filter_complex split=N`, every output tier's encoder pipeline lives in memory simultaneously. A 405MB 4K source with 5 encoded tiers (2160p+1440p+1080p+720p+540p) + source passthrough blew past an 8GB Docker VM and got SIGKILL'd (Signals.SIGKILL: 9) on Knowframes 2026-04-22.

**Why:** ffmpeg's filter_complex + var_stream_map is memory-heavy because the decoded frame gets split, then each split branch feeds an independent x264 encoder holding its own lookahead/reference buffers. Stream-copy variants (source passthrough) are fine — they barely use memory. Encoded variants are the ones that scale linearly.

**How to apply:**
- Cap simultaneous encoded tiers to **3** when using one-shot ffmpeg on ~8GB hosts. 4 works for <1080p sources; 5+ is risky past 500MB inputs.
- Skip 1440p by default — the jump 2160→1080→720 or 1080→720→540 covers most review bandwidths without doubling encoder count.
- Stream-copy tiers (`-c copy`) don't count against the cap.
- If you need more tiers (Frame.io parity), **rewrite to per-tier serial ffmpeg invocations** — one ffmpeg per quality, each producing its own HLS variant, then hand-write master.m3u8 combining them. Peak memory becomes bounded by a single x264 encode (~500MB–1GB for 1080p), total time ≈N × per-tier time (each pass re-decodes the source).
- Detect OOM via stderr or via `subprocess.CalledProcessError` with negative return code. Signal 9 = OOM kill on Linux.
- Docker Desktop on macOS has a fixed VM memory limit (usually 8GB). Raising it doesn't help if users' laptops have less RAM.
