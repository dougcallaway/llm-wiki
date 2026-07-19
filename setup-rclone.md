# Optional tooling: rclone

rclone syncs wiki files to cloud storage. It supports 70+ backends: OneDrive, Google Drive, S3, Backblaze B2, Dropbox, and many more.

`capture/` below means the wiki's capture directory — if `schema.md`'s `## Capture` section names a different folder, substitute it.

Three patterns, pick one:

| Pattern | What rclone syncs | When to choose |
|---------|------------------|----------------|
| **Complement to git — binaries only** | `capture/` only | git handles `wiki/`; you push to a remote like GitHub; rclone covers the binaries git skips |
| **Complement to git — full repo** | Entire wiki root including `.git/` | Single-user wiki; you want git history locally without pushing to a remote; rclone is the remote |
| **Alternative to git** | Entire wiki root (no `.git/`) | No git at all; history via cloud provider's built-in versioning |

**rclone vs. git for `wiki/`:** git gives you per-line diff history, structured commits, and true rollback at any granularity. rclone gives you simpler setup and works for any file type, but rollback depends on what you sync: the full-repo pattern preserves complete git history in the cloud (restore with `rclone sync`; `git log` still works); the alternative-to-git pattern relies on the cloud provider's file versioning (OneDrive, S3, GCS). Use git-as-remote if history matters and you need to access the repo from multiple machines; use rclone-as-remote for a single-user wiki that stays local.

**Install:**

```bash
# macOS
brew install rclone

# Debian/Ubuntu
sudo apt install rclone

# All platforms: see https://rclone.org/install/
```

**Setup:**

```bash
rclone config
```

Follow the interactive prompts for your chosen backend. Name the remote something memorable (e.g. `backup`). Verify access after setup:

```bash
rclone lsd backup:
```

**Sync — complement to git, binaries only:**

Add `capture/` to `.gitignore` so the binaries stay out of the git repo. If `schema.md`'s `## Capture` section names a different folder, gitignore that name instead — and if the capture directory lives outside the wiki root (or inside another git repository), skip this step; there is nothing to ignore here:

```
# Raw capture files — backed up via rclone, not git
capture/
```

Then sync only `capture/`:

```bash
rclone sync <wiki-root>/capture/ backup:wiki-capture/
```

**Sync — complement to git, full repo (rclone as the remote):**

Sync the entire wiki root including `.git/`. This preserves full git history in the cloud without needing GitHub:

```bash
rclone sync <wiki-root>/ backup:my-wiki/
```

To restore on a new machine:

```bash
rclone sync backup:my-wiki/ <wiki-root>/
# git log, git checkout, etc. all work — .git/ is intact
```

**Sync — alternative to git (no git):**

```bash
rclone sync <wiki-root>/ backup:my-wiki/ --exclude ".git/**"
```

The `--exclude ".git/**"` flag is a safety net in case a `.git/` directory exists; omit it if the wiki has never used git.

**`sync` vs. `copy`:** `rclone sync` mirrors the source — it adds new files and removes files deleted locally. Use `rclone copy` instead if you want the destination to only grow (never delete).

**Post-commit hook (recommended when using git):**

Wire rclone to git's post-commit hook so every commit automatically triggers a sync — no manual reminders needed:

```bash
cat > <wiki-root>/.git/hooks/post-commit << 'EOF'
#!/bin/sh
command -v rclone >/dev/null 2>&1 && rclone sync <source-path> <remote>:<destination-path>
EOF
chmod +x <wiki-root>/.git/hooks/post-commit
```

Replace `<source-path>`, `<remote>`, and `<destination-path>` with the values from `schema.md`'s `## Backup` section. The `command -v` guard makes the hook a no-op if rclone is not installed, so it never blocks a commit.

Note: `.git/hooks/` is not tracked by git. If you restore the repo from rclone and need to recreate the hook, re-run the commands above (or ask the agent — the command is in `schema.md`).

**The agent's role:** The agent does not run rclone automatically. If `.git/hooks/post-commit` exists, skip sync reminders — the hook fires on every commit. If no hook exists but `schema.md` contains a `## Backup` section, remind the user to sync after each organize, distill, express, or calibrate pass using the exact command from `schema.md`. When the pattern is `rclone-only` (no git), the agent skips git commit suggestions entirely.
