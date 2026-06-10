# Optional tooling: Git

Git gives the wiki per-file diff history and true rollback — the one thing `log.md`
cannot provide. It's the right choice if you want to see exactly which sentences
changed in a distill pass, or restore any prior state of the wiki.

**Setup:**

Only do this if the wiki root is not already inside a parent git repo (nested repos are rarely intended). Then:

```bash
cd <wiki-root>
git init
```

Create `<wiki-root>/.gitignore`:
```
# OS
.DS_Store
Thumbs.db
desktop.ini

# Editor
.obsidian/
```

Ask the user: *"Do you want to exclude `capture/assets/`? Exclude if you care about repo size; track it if you want the wiki fully self-contained."* Add `capture/assets/` to `.gitignore` if yes.

```bash
git add .
git commit -m "init: wiki created"
```

**Commit convention:** Mirror the `log.md` entry format in commit messages so `git log --oneline` and `log.md` are readable side by side:
- `organize: <Source Title>`
- `distill: <Page Title> (level N->N+1)`
- `express: <Output Title>` (also used when a filed Query answer is committed)
- `lint: <date> (<N> fixed)`

**Rollback:**

Find the target commit:
```bash
git log --oneline
```

Restore the entire `wiki/` directory:
```bash
git checkout <commit-hash> -- wiki/
git commit -m "rollback: to <commit-hash>"
```

Restore a single page:
```bash
git checkout <commit-hash> -- wiki/concepts/transformer.md
git commit -m "rollback: transformer to <commit-hash>"
```

Note: `git checkout <hash> -- <path>` stages the files but does not commit — always follow it with a commit to record the rollback in history.

**Claude's role:** When `.git` exists in the wiki root, Claude suggests a commit after each organize, distill, express, and calibrate operation and waits for explicit confirmation before running it. Claude never commits without confirmation, and skips all git behavior when no `.git` exists in the wiki root.
