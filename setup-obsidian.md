# Optional tooling: Obsidian

These two Obsidian tools integrate cleanly with the `capture/` workflow and are worth
setting up if the user is using Obsidian as their wiki viewer.

## Obsidian Web Clipper

A browser extension that converts web articles to markdown with a single click.

**Setup:** Install from [obsidian.md/clipper](https://obsidian.md/clipper). Point it
at the `capture/` directory as the save location. Clipped articles land there as
markdown files, ready to organize — no copy-pasting required.

**Claude's role:** When the user says "I clipped something", check `capture/` for new
files and offer to organize them.

## Download attachments hotkey

Obsidian can download all inline images from a clipped article to a local folder,
so Claude can read them directly rather than relying on URLs that may break.

**Setup:** In Obsidian Settings → Files and links, set "Attachment folder path" to
`capture/assets/`. Then in Settings → Hotkeys, search for "Download attachments for
current file" and bind it to a hotkey (e.g. `Ctrl+Shift+D`). After clipping an
article, hit the hotkey to pull all images local.

**Claude's role on organize:** When reading a source that has image references pointing
to `capture/assets/`, read the text first, then view referenced images separately for
additional context. Note that images can't be read inline with the markdown in one
pass — treat them as supplementary.
