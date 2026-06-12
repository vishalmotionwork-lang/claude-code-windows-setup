---
name: feedback_tiptap_editorcontent
description: Tiptap EditorContent must mount exactly once per editor — pass as React node prop for dual layouts
type: feedback
---

Never mount two `<EditorContent editor={editor} />` components for the same editor instance. When desktop and mobile layouts both render via CSS class hiding (`hidden lg:flex` / `lg:hidden`), React mounts BOTH — the second `EditorContent` steals the editor DOM and breaks `ReactNodeViewRenderer` portals (custom node views like SectionNode won't render).

**Why:** Spent hours debugging why SectionNodes weren't rendering. The editor JSON had sections, the extension was registered, but ReactNodeViewRenderer wasn't firing. Root cause: two EditorContent mounts.

**How to apply:**
- Render `<EditorContent>` exactly once in the parent component
- Pass the rendered output as a React node prop: `editorNode={editor ? <EditorContent editor={editor} /> : null}`
- Child components render `{editorNode}` instead of `<EditorContent editor={editor} />`
- The `editor` instance can still be passed separately for toolbar/BubbleMenu interactions
