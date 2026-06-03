---
name: llm-wiki
description: >
  Maintains a persistent, Claude-owned personal knowledge base (wiki) on the local
  filesystem using Karpathy's LLM Wiki pattern and Forte's PARA and CODE methods. Trigger when
  the user wants to build or query a knowledge base, capture notes or sources, or produce
  output from accumulated knowledge. Key phrases: "my wiki", "add this to my wiki",
  "capture this", "distill", "what do I know about X", "write a draft from my notes".
---

# LLM Wiki Skill

A Claude-maintained personal knowledge base. Claude does all the writing and bookkeeping; the user does the sourcing and thinking. See README.md for conceptual background.

---

## Directory layout

```
<wiki-root>/
├── capture/           # All incoming content — quick captures and source documents
│   └── assets/        # Locally downloaded images
├── wiki/              # Claude-owned markdown pages
│   ├── index.md       # Content catalog — read first on every query
│   ├── log.md         # Append-only chronological record
│   ├── overview.md    # High-level synthesis of the whole wiki
│   ├── projects/      # Active deliverables (one folder per project)
│   ├── areas/         # Ongoing responsibilities
│   ├── resources/     # Shared reference-document pool
│   └── archive/       # Inactive projects/areas (created on demand)
└── CLAUDE.md          # The schema — wiki conventions and domain config
```

### Organizing model
Three orthogonal axes make the wiki easy to browse and query for both humans and machines:

| Axis | Encoded by |
|------|-----------|
| **Location** | **PARA bucket** (project/area/resource/archive) — the directory the page lives in |
| **Links** | **Cross-references** from effort pages (projects/areas) to the resources they depend on |
| **Tags** | **Namespaced tags** (e.g. `technology/x`, `vendor/y`) drawn from `CLAUDE.md`'s `## Tag vocabulary` |

Analyses and member pages live **inside** their owning project/area folder. `CLAUDE.md` is authoritative on all conventions.

**Claude owns everything in `wiki/`. Claude never modifies `capture/`.**

`capture/` holds two kinds of content:
- **Quick captures** — timestamped notes/links/quotes dropped in without processing, named `<timestamp>-<slug>.md`
- **Source documents** — articles, PDFs, transcripts, and other raw material ready to organize

Both are immutable once written.

---

## Startup: finding or creating a wiki

When the user invokes this skill, Claude should:

1. **Locate the wiki root.** Check if a `CLAUDE.md` or `wiki/index.md` exists in the
   current directory or a parent. If found, that's the wiki root — read `CLAUDE.md`
   and `wiki/index.md` to orient.

2. **If no wiki exists,** ask the user:
   - What topic/domain is this wiki for?
   - Where should the root directory live?
   Then initialize the structure (see **Init** below).

3. **If ambiguous** (multiple candidates), ask the user which one.

---

## Init

When creating a fresh wiki:

```bash
mkdir -p <root>/capture/assets <root>/wiki
```

Create `<root>/CLAUDE.md` using the following template, filled in with the user's domain details:

```markdown
# CLAUDE.md — <Wiki Name>

## Domain
<One sentence describing what this wiki is for and who it serves.>

## Page types
- **entity** — a person, organization, model, tool, or named thing
- **concept** — an idea, technique, or principle
- **source** — a processed reference document (article, paper, transcript, note); lives in `resources/`
- **analysis** — a comparison, synthesis, decision doc, or express output; owned by one area/project
- **overview** — a high-level synthesis page

## Organizing model
Three orthogonal axes make the wiki easy to browse and query for both humans and machines:

| Axis | Encoded by |
|------|-----------|
| **Location** | **PARA bucket** (Projects/Areas/Resources/Archives) — the directory the page lives in |
| **Links** | **Cross-references** from effort pages (projects/areas) to the resources they depend on |
| **Tags** | **Namespaced tags** (e.g. `technology/x`, `vendor/y`) drawn from `## Tag vocabulary` below |

## Frontmatter fields
All pages use: `type`, `title`, `tags` (namespaced topics only, from `## Tag vocabulary` below), `last_updated`, `source_count`, `distill_level`

## Domain-specific notes
<Any conventions specific to this domain, e.g. "pages for characters use type: entity and include an 'appears_in' field".>

## Tag vocabulary
Namespaced topic tags only. Add here before using; one canonical spelling per concept.
People and companies are entities (a page + a link), not tags.

<!-- Define namespaces that fit the domain, e.g.: -->
### technology/
### vendor/
### process/

## Backup
<!-- omit this section if no backup is configured -->
Pattern: <binaries-only | full-repo | rclone-only>
Command: rclone sync <source-path> <remote>:<destination-path>
```

Also create `<root>/wiki/projects/`, `areas/`, `resources/` directories.

Create `<root>/wiki/index.md`:
```markdown
# Index
_Last updated: <date>_

## Resources
| Page | Summary | Date |
|------|---------|------|

## Entities

## Concepts

## Analyses
_Grouped by parent area/project._
```

Create `<root>/wiki/log.md`:
```markdown
# Log

## [<date>] init | Wiki created
Domain: <domain>
```

Create `<root>/wiki/overview.md` as a brief placeholder.

Finally, check whether the wiki root is already inside a parent git repo. **If it is, do not offer git setup** — a nested repo is rarely intended. **If it isn't**, ask the user: *"Do you want to enable git version control for this wiki? It gives you per-file rollback and full history."* If yes, read `setup-git.md` and follow its setup steps.

Then ask about cloud backup: *"Do you want to back up this wiki to cloud storage via rclone? Options: (1) binaries only — rclone covers `capture/`, git covers `wiki/`, push `wiki/` to a remote like GitHub; (2) full repo — rclone syncs everything including `.git/`, no GitHub needed (good for single-user wikis); (3) rclone only — no git, rclone is your only backup. Or skip for now."*

If the user chooses a pattern, read `setup-rclone.md`, ask for the rclone remote name and destination path, then add a `## Backup` section to `CLAUDE.md`:
```
## Backup
Pattern: <binaries-only | full-repo | rclone-only>
Command: rclone sync <source-path> <remote>:<destination-path>
```
For **binaries-only**, `<source-path>` is `<wiki-root>/capture/`. For **full-repo** and **rclone-only**, it is `<wiki-root>/`. If the user skips backup setup, omit the `## Backup` section entirely.

If git was set up **and** an rclone pattern was chosen, also create the post-commit hook (see `setup-rclone.md` for the hook script). Skip this step for the **rclone-only** pattern (no git, no hook).

---

## Operations

### Capture

Triggered by: "capture this", "quick note", "save this for later", "add to inbox",
or any short idea/link/quote the user tosses over without asking for full processing.

**Flow:**

1. Save the item to `capture/<timestamp>-<slug>.md` with minimal structure:
   ```markdown
   ---
   captured: <date>
   source: <url or "pasted">
   ---
   <raw content or brief note>
   ```
2. Confirm: "Captured to capture/. You have N unprocessed items — want me to organize any?"

---

### Organize  _(O in CODE)_

Triggered by: "organize this", "process my inbox", "add this to the wiki",
"read this article/paper/transcript", dropping a file in `capture/`, or pasting content
directly with the intent to integrate it.

**Flow:**

1. **Read the source.** If it's in `capture/`, read it from there. If pasted, save
   to `capture/<slug>.md` first.

2. **Discuss with the user** — but only if the content is surprising, contradicts
   existing wiki pages, or the user's intent is unclear. Surface one key takeaway and
   ask one focused question at most. Skip discussion entirely if: the user pasted
   content directly and gave no other instruction, the user said "just organize it",
   or the source is straightforward (a single clear topic, no contradictions). Default
   is to proceed, not to ask.

3. **Read `wiki/index.md`** to understand what already exists.

4. **Assign topic tags + note which efforts it serves.** Scan `CLAUDE.md`'s `## Tag vocabulary`
   for existing namespaced tags. Choose the topics that fit, adding new ones to `CLAUDE.md` first.
   Separately, note which projects/areas the document serves — record that as forward links on
   those project/area pages (step 6), not as a tag. Confirm briefly if unclear:
   > "Topics `vendor/tektelic` + `technology/lorawan`; serves `project/migration`. OK?"

5. **Write a source summary page** in the reference pool — `wiki/resources/<slug>.md`
   (`CLAUDE.md` is authoritative on the pool's folder name and conventions):
   ```markdown
   ---
   type: source
   title: <title>
   date_organized: <date>
   tags: [vendor/tektelic, technology/lorawan]
   distill_level: 0
   ---
   # <Title>
   **Summary:** <2–4 sentence synthesis>
   **Key claims:** bullet list
   **Cross-references:** links to entity/concept pages this touches
   ```

6. **Update existing wiki pages** that this source extends, contradicts, or enriches.
   A single source typically touches 5–15 pages. For each affected page:
   - Add new information
   - Note contradictions inline: `> ⚠️ Contradiction: <source> says X, but <other> says Y`
   - **For each project/area page that uses this source:** add a forward cross-reference link to the source page (e.g. in a "Resources" or "References" section). This is how the resource-effort relationship is recorded — on the effort side, not on the resource.

7. **Create new pages** for any entity, concept, or theme that appears significantly
   in the source and doesn't have a page yet. File each in the right bucket directory.

8. **Update `wiki/index.md`** — add the source to the sources table, add/update
   entries for any new or significantly changed pages.

9. **Append to `wiki/log.md`**:
   ```
   ## [<date>] organize | <Source Title>
   Pages updated: <list>
   New pages: <list>
   ```

   **If a `.git` directory exists in the wiki root**, suggest: `git add . && git commit -m "organize: <Source Title>"`. Wait for user confirmation before running.

10. **If the source came from `capture/`,** leave it in place — `capture/` is immutable.
    The wiki now contains the processed knowledge; the capture file is its provenance.

11. **Optionally update `wiki/overview.md`** if the source meaningfully shifts the
    overall synthesis.

---

### Distill  _(D in CODE)_

Triggered by: "distill this page", "distill my notes on X", "progressive summary",
or automatically suggested by Claude when a page reaches 5+ sources. **Not** triggered
by questions like "what are the key ideas on X" — that's a Query.

Forte's progressive summarization: each pass bold-highlights the most important
sentences, then a further pass extracts those into a short executive summary at the
top. Claude applies this to wiki pages.

**Flow:**

1. **Identify pages to distill.** Either the user names a page/topic, or Claude
   suggests candidates: pages with high `source_count`, pages last distilled long ago,
   or pages the user is about to use for Express.

2. **Read the page** and its current `distill_level` (0 = raw, 1 = bolded, 2 = summary added, 3 = condensed).

3. **Apply the next distillation level:**

   - **Level 0 → 1:** Bold the most important phrases and sentences (≈20% of content).
     Don't remove anything yet.
   - **Level 1 → 2:** Add a `## ✦ Distilled Summary` block at the top — 3–5 bullets
     capturing the essential claims. The full content remains below.
   - **Level 2 → 3:** Condense the body, removing detail that is fully captured in the
     summary. Preserve anything the summary doesn't cover. The page should now be
     significantly shorter without losing meaning.

4. **Update `distill_level`** in frontmatter and `last_distilled` date.

5. **Show the user the before/after** for approval before writing. Or if the user said
   "just distill it", write directly.

6. **Append to log:**
   ```
   ## [<date>] distill | <Page Title>
   Level: <N> → <N+1>
   ```

   **If `.git` exists in the wiki root**, suggest: `git add . && git commit -m "distill: <Page Title> (level <N>-><N+1>)"`. Wait for user confirmation before running.

---

### Express  _(E in CODE)_

Triggered by: "write a draft about X", "create a report on Y", "I need to make a
decision about Z", "turn my wiki into something I can share/publish/send". The key
signal is a finished artifact for an audience or purpose outside the wiki. **Not**
triggered by "summarize what I know about X" — that's a Query.

**Flow:**

1. **Clarify the output type** if not obvious:
   - **Draft** (blog post, essay, article) — flowing prose, argument-led
   - **Report** (research summary, briefing) — structured, comprehensive, cited
   - **Decision doc** (options + recommendation) — problem statement, options,
     criteria, recommendation, risks

   Claude picks the most fitting type based on context and confirms briefly.

2. **Read `wiki/index.md`** and pull all relevant pages — prioritize pages with
   high `distill_level` (already refined) and pages in the relevant project/area folder or
   tagged with related topics. If key pages are at `distill_level` 0, suggest distilling first.

3. **Draft the output,** drawing on wiki content with inline citations to source pages.
   Do not reproduce wiki content verbatim — synthesize and rewrite for the target format.

4. **Determine the filing location.** Every analysis belongs to exactly one area or project — the one
   it serves. Infer it from context (the user's active project, the folder/topics of the source
   pages used) and confirm briefly if unclear:
   > "I'll file this under `project/methanetrack-infra-migration` — correct?"

5. **For drafts/reports:** write the output **inside that project/area's folder** alongside its
   `index.md` (e.g. `wiki/projects/<name>/<slug>.md`, `wiki/areas/<name>/<slug>.md`),
   and give it namespaced topic tags. Promote a flat area/project page to a folder if needed.
   `CLAUDE.md` is authoritative on placement. Then update index + log.

6. **For decision docs:** use this structure:
   ```markdown
   ## Decision: <Question>
   **Context:** ...
   **Options:**
   | Option | Pros | Cons |
   |--------|------|------|
   **Criteria:** ...
   **Recommendation:** ...
   **Risks & open questions:** ...
   **Sources:** links to wiki pages used
   ```
   File it under its parent, same as drafts/reports (step 5).

7. **Link the analysis from its parent page** (an "Analyses" section on the area/project page) so
   it isn't an orphan, and add it under the matching parent group in `wiki/index.md`.

8. **Append to log:**
   ```
   ## [<date>] express | <Output Title>
   Type: draft | report | decision
   Parent: <area-or-project>
   Filed: <path to the analysis>
   Sources used: <list of wiki pages>
   ```

   **If `.git` exists in the wiki root**, suggest: `git add . && git commit -m "express: <Output Title>"`. Wait for user confirmation before running.

**External references:** When citing code, PRs, or artifacts outside the wiki, prefer
stable pointers over fragile ones. A branch name or local file path will go stale;
a commit hash + path or a full URL to a specific revision will not:
- Stable: `https://github.com/org/repo/blob/abc1234/src/auth.py`, a PR link, a tagged release
- Fragile: `/path/to/repo/src/auth.py`, a branch name, a bare line number

---

## Utilities

Operations that support the wiki but are not part of the CODE workflow.

---

### Query

Triggered by: a question about the wiki's domain — "what does my wiki say about X",
"what do I know about Y", "compare X and Y", "what's the connection between X and Z".
The key signal is retrieval and synthesis in chat, not producing a finished artifact
(that's Express) and not improving a page (that's Distill).

**When the intent is ambiguous** (e.g. "summarize what I know about transformers"), ask one question before proceeding: *"Is this for your own reference, or a finished artifact for someone else?"* — and route to Query or Express accordingly.

**Flow:**

1. **Read `wiki/index.md`** to find relevant pages.

2. **Read those pages** — up to 5–7 pages maximum. Prioritize pages whose titles most
   directly match the query; follow links only if the linked page is clearly necessary
   to answer. On large wikis, breadth-first reading without a cap can silently exhaust
   the context window.

3. **Synthesize an answer** in chat with citations to wiki pages (relative links).

4. **Offer to file non-trivial answers back** — if the answer involved a comparison,
   a connection, or an analysis the user hadn't made explicit:
   > "Want me to save this as a wiki page? It would live inside its parent area/project,
   > e.g. `wiki/projects/<name>/<slug>.md`."
   If yes, write it as an analysis (namespaced topic tags, file it inside the owning
   project/area's folder per the Express rules) and update the index + log.

   **If the answer was filed and `.git` exists in the wiki root**, suggest: `git add . && git commit -m "express: <Answer Title>"`. Wait for user confirmation before running. (Use `express:` since a filed query answer is conceptually an express output.)

**Output formats:** Prose by default. Tables for comparisons. Lists for timelines.
If the answer is dense enough to be reused, offer to write it as a full wiki page —
at that point it's become an Express output.

---

### Lint

Triggered by: "health check", "audit the wiki", "clean up", "find gaps", "lint".

**Flow:**

1. Read `wiki/index.md` and all wiki pages.

2. Check for and report:
   - **Contradictions** — pages making conflicting claims
   - **Orphans** — pages with no inbound links from other wiki pages
   - **Unused resources** — resource pages that no project/area page links to (may be general-purpose, or may be forgotten after an effort ended)
   - **Stale claims** — pages that haven't been updated despite newer sources that touch the same topic (check `log.md` for ordering)
   - **Missing pages** — concepts mentioned frequently across pages but lacking their own page
   - **Dead links** — `[[wikilinks]]` or relative links pointing to non-existent pages
   - **Thin pages** — pages with less than 3 meaningful claims

3. Produce a lint report:
   ```markdown
   ## Wiki Lint Report — <date>
   ### Contradictions (needs human decision)
   - ...
   ### Orphan pages
   - ...
   ### Unused resources (no project/area links to these)
   - ...
   ### Missing pages (suggested)
   - ...
   ### Dead links
   - ...
   ### Thin pages
   - ...
   ```

4. Ask the user which issues to fix now. Fix the approved ones and append to `log.md`:
   ```
   ## [<date>] lint | Lint pass
   Issues found: <N>
   Issues fixed: <list>
   Deferred: <list>
   ```

   **If any fixes were applied and `.git` exists in the wiki root**, suggest: `git add . && git commit -m "lint: <date> (<N> fixed)"`. Wait for user confirmation before running. If everything was deferred, no commit is needed.

---

## Page conventions

### Frontmatter (YAML)
Every wiki page should have:
```yaml
---
type: entity | concept | source | analysis | overview
title: <human-readable title>
tags: [<namespace/topic>, <namespace/topic>]
last_updated: <date>
source_count: <N>       # how many sources have touched this page
distill_level: 0        # 0=raw, 1=bolded, 2=summary added, 3=condensed
last_distilled: <date>  # omit if never distilled
---
```

`tags` carry **namespaced topic keywords only**, drawn from `CLAUDE.md`'s `## Tag vocabulary`
(e.g. `technology/postgres`, `vendor/acme`, `compliance/soc2`, `process/hiring`).

### Cross-references
Use relative markdown links: `[Concept Name](../concepts/concept-name.md)`
Also support `[[wikilink]]` style if the user is using Obsidian.

Resource pages use `**Cross-references:**` for entity/concept links. Which efforts use a resource is recorded as links **on the project/area page** (in a "Resources" or "References" section), not on the resource itself. A resource's usage is therefore discoverable by checking which project/area pages link to it — Lint flags resources with no inbound project/area links as potentially orphaned.

### Contradiction markers
```
> ⚠️ **Contradiction:** [Source A](../sources/a.md) claims X while [Source B](../sources/b.md) claims Y. Unresolved.
```

### Confidence markers (optional)
If the wiki domain benefits from epistemic tagging:
```
> 🔵 **Well-established** | 🟡 **Contested** | 🔴 **Speculative**
```

---

## index.md format

Keep it scannable — one-line summaries only.

```markdown
# Index — <Wiki Name>
_<N> resources | <M> pages | Last updated: <date>_

## Resources
| Page | Summary | Organized |
|------|---------|---------|
| [Title](resources/slug.md) | One sentence | 2026-04-01 |

## Entities
| Page | Summary |
|------|---------|

## Concepts
| Page | Summary |

## Analyses
_Analyses live inside their parent area/project; grouped here by parent for discoverability._

### <parent area or project>
| Page | Summary |
|------|---------|
```

---

## log.md format

Append-only. Each entry starts with `## [YYYY-MM-DD]` so it's grep-parseable.
Operation types: `init`, `capture`, `organize`, `distill`, `express`, `query`, `lint`.

```markdown
# Log

## [2026-04-01] init | Wiki created
Domain: AI Research

## [2026-04-02] organize | Attention Is All You Need
Pages updated: transformer, attention-mechanism, encoder-decoder
New pages: multi-head-attention, positional-encoding

## [2026-04-03] distill | transformer
Level: 0 → 2

## [2026-04-04] express | Draft: The Case for Attention-Only Architectures
Type: draft
Parent: project/attention-post
Filed: wiki/projects/attention-post/attention-only-draft.md
Sources used: transformer, multi-head-attention, attention-is-all-you-need
```

---

## Optional tooling

Setup guides live in separate files — load the relevant one on demand, not on every wiki operation:

| File | When to load |
|------|-------------|
| `setup-git.md` | User asks about git setup, rollback, or commit conventions; or during Init when git is requested |
| `setup-rclone.md` | User asks about cloud backup or sync; or during Init when a backup pattern is requested |
| `setup-obsidian.md` | User mentions Obsidian, web clipping, or asks about the clipper workflow |

**Operational reminders (no file load needed):**
- If `.git` exists: suggest a commit after organize, distill, and express — wait for confirmation
- If `.git/hooks/post-commit` exists: skip rclone sync reminders — the hook fires automatically
- If no hook but `CLAUDE.md` has a `## Backup` section: remind the user to sync after each operation using the exact command from `CLAUDE.md`
- If `rclone-only` pattern (no git): skip git commit suggestions entirely

---

## Behavioral principles

- **Claude never modifies `capture/`**. That's the source of truth — both quick captures and source documents live there, immutable.
- **Capture is frictionless.** Inbox items require zero processing — save first, think later.
- **Be thorough on cross-references.** A page that isn't linked to is nearly invisible.
- **Contradictions are first-class citizens.** Don't silently pick a side — mark them
  and let the user decide.
- **PARA reflects the user's current life, not the content.** The same resource may serve multiple efforts — record those dependencies as forward links on each project/area page. When in doubt about which efforts a resource serves, ask.
- **Distillation is lossy by design.** Optimize for resonance, not completeness — keep what the user would want to rediscover six months from now.
- **Distill before Express.** If asked to express from pages at distill_level 0, suggest
  distilling first — the output will be sharper.
- **File good answers and outputs back.** Insights and drafts shouldn't disappear into
  chat history — they're wiki pages now.
- **Keep the index lean.** One-line summaries only. Detail lives in the pages.
- **The log is append-only.** Never edit past entries.
- **When in doubt about page structure, consult `CLAUDE.md`** — that's the domain
  configuration for this specific wiki.
- **Prefer updating existing pages over creating new ones** unless the topic genuinely
  warrants its own page (recurring, substantial, cross-referenced by multiple sources).
