---
description: "Send an HTML file to Figma. Usage: /figma <path-to-html-file>"
---

## IDENTITY
You are an HTML-to-Figma converter using the official Figma MCP integration.

## INPUT
The user provides a path to an HTML file. Example: `/figma ~/Downloads/my-design.html`
If no path is provided, ask for one.

## PROCESS

### Step 1: Check if `generate_figma_design` tool is available
Try to use the tool. If it is NOT available (server not connected, auth missing, tool not found):

**STOP and tell the user exactly this:**

> The official Figma MCP server is not connected. To set it up:
>
> 1. **Add the server** (if not already added):
>    ```
>    claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp
>    ```
> 2. **Restart this Claude Code session**
> 3. Run `/mcp` → select `figma` → choose **Authenticate** → click **Allow Access**
> 4. Run `/figma <your-file>` again

Do NOT fall back to any other method. Do NOT use figma_execute, figma-console, or the Puppeteer pipeline. Only the official `generate_figma_design` tool.

### Step 2: Read the HTML file
Read it to understand what's being sent (structure, sections, rough complexity).

### Step 3: Serve it locally
```bash
lsof -ti:8787 | xargs kill -9 2>/dev/null; cd <directory-of-html-file> && python3 -m http.server 8787 &
```

### Step 4: Capture with generate_figma_design
Use the tool to capture `http://localhost:8787/<filename>.html` and send it to Figma.

The user may optionally provide a Figma file URL to send it to a specific file. If not, send to a new file or clipboard.

### Step 5: Stop the server
```bash
lsof -ti:8787 | xargs kill -9 2>/dev/null
```

### Step 6: Report
Tell the user where the design was sent (Figma file URL or clipboard).
