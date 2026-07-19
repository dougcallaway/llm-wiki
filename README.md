# Wikismith

**A knowledge base your AI agent builds and maintains for you — plain markdown files that get richer every time you add a source.**

You drop in articles, notes, and links. Your agent reads them, files the knowledge into interlinked pages, flags where new sources contradict old ones, and keeps an index so nothing gets lost. Instead of re-reading the same documents every time you have a question, you ask your agent — and it answers from everything the wiki holds.

It's an [Agent Skill](https://code.claude.com/docs/en/skills) (the open `SKILL.md` standard), so it works with any AI coding agent that can read and write files in a folder. Claude Code is the tested reference; Codex, Gemini CLI, Cursor, and other Agent Skills–compatible tools should work too (reports welcome — see [Compatibility](#compatibility)).

## What you need

- **An AI coding agent** — a program that runs on your own computer, talks with you in plain English, and can read and write your files. [Claude Code](https://claude.com/claude-code) is the tested one; note it [requires a paid Claude plan](https://code.claude.com/docs/en/setup). Codex, Gemini CLI, and Cursor should work too.
- **A folder.** Your whole wiki is ordinary files on your machine — nothing else to sign up for.
- **One setup session.** If you've never used a terminal, installing the agent is the single technical step; everything after that happens by asking in plain English. [Obsidian](https://obsidian.md) (free) is optional but a lovely way to view what your agent builds.

## What you get

- **One knowledge base that compounds.** Every source you add updates existing pages, adds cross-references, and gets logged. The wiki is worth more after the tenth source than the sum of ten separate notes.
- **Answers, not searches.** Ask "what do I know about X" and get a synthesis with links to the pages behind it — not a pile of documents to re-read.
- **Plain markdown you own.** No database, no lock-in. The whole wiki is folders of `.md` files you can read, edit, back up, or open in any markdown app.
- **Frictionless capture.** Toss things into `capture/` without processing. They wait there until you ask to organize them.

## How it works

Two ideas do the work.

**[Karpathy's LLM Wiki pattern.](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** Rather than re-deriving answers from raw documents every time (the usual "retrieval" approach), your agent builds and maintains a *persistent wiki*: structured, interlinked markdown pages that improve with every source. Integrating a source updates the pages it touches, flags contradictions, and adds cross-references.

**[Forte's CODE method](https://fortelabs.com/blog/the-4-levels-of-personal-knowledge-management/)** maps onto four operations:

| CODE step | Operation | What your agent does |
|-----------|-----------|-----------------|
| **C**apture | `capture` | Drop ideas and links into `capture/` without processing |
| **O**rganize | `organize` | Integrate captures into the wiki; update the pages they touch |
| **D**istill | `distill` | Progressively compress pages to their essential insights |
| **E**xpress | `express` | Produce a draft, report, or decision doc that cites its wiki sources — a starting point you finish |

Three utility operations sit outside CODE: `query` (retrieve and synthesize from the wiki), `calibrate` (learn your writing voice so `express` drafts start closer to something you'd keep), and `lint` (a health check for pages nothing links to, contradictions, and dead links).

Your job: capture, direct, and make the final call. The agent's job: everything else.

## schema.md — your wiki's schema

Each wiki has a `schema.md` at its root that the agent reads at the start of every session. It defines the domain, page types, organizing conventions, and tag vocabulary for that specific wiki. When you initialize a new wiki, the agent creates a sensible default — refine it together as you learn what works for your domain.

> Wikis created with an earlier version used `CLAUDE.md` for this file. Those still work: the skill reads `schema.md` if present and falls back to `CLAUDE.md`. Rename it to `schema.md` when convenient so any agent, not just Claude, treats it as an ordinary file.

## Design principles

- **Capture is frictionless.** `capture/` is a holding area, not the wiki. Drop things in without processing; they sit there until you ask to organize them. (You can rename the folder, or point it at one you already use — a web clipper's target, say — in `schema.md`.)
- **`capture/` is never edited.** Whatever you capture stays exactly as you captured it; only the wiki pages built from it evolve. You can always check a page against its original.
- **Cross-references compound value.** A page with no inbound links is nearly invisible. Be thorough on connections, not just summaries.
- **Distillation is lossy by design.** The goal is resonance, not completeness — keep what you'd want to rediscover six months from now.
- **Outputs belong in the wiki.** A good draft or analysis is filed as a page, not left behind in chat history.
- **Drafts are yours to finish.** `express` assembles a starting draft that cites the wiki pages it drew from; you review, finish, and own what goes out.
- **Voice is for outputs only.** `calibrate` teaches your agent your writing voice and `express` applies it — but internal pages stay in a plain reference voice, so the wiki itself always reads the same way.

## Install

**The easy way (any agent):** once your agent is installed, paste this into it:

> Install the wikismith skill by cloning https://github.com/dougcallaway/wikismith into my skills folder, then confirm it loaded.

The agent performs the technical steps itself. (For Claude Code the skills folder is `~/.claude/skills/`, and the skill is then available as `/wikismith` in any session.)

**The terminal way (Claude Code):**

```bash
git clone https://github.com/dougcallaway/wikismith ~/.claude/skills/wikismith
```

**Other agents** — Codex, Gemini CLI, Cursor, and other tools that support the `SKILL.md` standard load skills from their own skills directory. Clone this repo there (check your tool's skills documentation for the exact path). Everything the skill does is plain file reading and writing, so no Claude-specific features are required.

**No git?** The green **Code → Download ZIP** button on this page works too — unzip into your skills folder. The clone route is still better where possible: it lets your agent [update the skill for you](#updating).

## Compatibility

The wiki is just markdown files and folders, so it opens in Obsidian, VS Code, or any markdown editor. (In Obsidian: **Open folder as vault** on your wiki folder, and you're browsing it.) Two conventions keep it portable and future-proof:

- **Use relative markdown links** — `[Concept](../resources/concept.md)` — as the default for connections between pages. They resolve the same in every tool. `[[wikilinks]]` work if you view the wiki in Obsidian, but they aren't part of [standard Markdown](https://commonmark.org/), so prefer relative links for anything you want other tools to read as a connection.
- **Folders are the hierarchy, and a page's path is its identity.** Renaming or moving a page means updating the links that point to it. The `lint` operation catches links left dangling.

### Works with Verdondo

A wiki you build with this skill is made of what **[Verdondo](https://github.com/verdondo)** — a visual tool in development that shows a folder of pages like these as a map you can view and edit as naturally as drawing on a whiteboard — is built to read: plain markdown pages with frontmatter (the small info block at the top of a page), connected by relative links, organized in folders. Each wiki defines its own page schema (yours lives in `schema.md`), and Verdondo reads the format without caring which schema produced it — verified against Verdondo's wiki backend. Verdondo keeps its view data in a `.verdondo/` folder and `.canvas` sidecar files alongside your pages; the skill leaves those alone, and so should you.

## Getting help

- **Questions and ideas** — [Discussions](https://github.com/dougcallaway/wikismith/discussions). "How do I…" belongs here, and non-technical questions are welcome — this skill exists for people who'd rather not think about the technical layer.
- **Something broke** — [open an issue](https://github.com/dougcallaway/wikismith/issues/new/choose). Tip: ask your agent to write the report with you — it was there when the problem happened, and the template tells it what to include.

## Credits

Built on the ideas of others, credited here in [TASL format](https://wiki.creativecommons.org/wiki/Best_practices_for_attribution) (Title, Author, Source, License):

- **The LLM Wiki pattern** — Andrej Karpathy — https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f — no license declared; the note explicitly invites adaptation. The idea of an AI agent maintaining a structured, interlinked knowledge base between you and raw sources.
- **The CODE method and the PARA method** — Tiago Forte (Forte Labs) — https://fortelabs.com/blog/the-4-levels-of-personal-knowledge-management/ and https://fortelabs.com/blog/para/ — © the author, referenced descriptively. CODE (Capture, Organize, Distill, Express) is the knowledge workflow this skill implements; PARA (Projects, Areas, Resources, Archives) is one organizing scheme the default schema supports.

> **Not affiliated with or endorsed by Forte Labs or Andrej Karpathy.** "Building a Second Brain," "BASB," and "PARA" are marks of Forte Labs; they are used here only to describe the methods this skill adapts.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, adapt it. Attribution is appreciated but not required.

## What "1.0" promises

The things your wiki depends on are stable: the page format (plain markdown, frontmatter, relative links, folders) and the rule that `capture/` is never edited. New operations and refinements arrive in minor versions. Anything that would change how existing wikis are read gets a major version — and a migration the agent performs for you; you never restructure your wiki by hand (today's example: wikis whose schema file still has its old `CLAUDE.md` name keep working and are offered a rename).

## Updating

Ask your agent — *"update my wikismith skill"* — or run it yourself:

```bash
git -C ~/.claude/skills/wikismith checkout main && git -C ~/.claude/skills/wikismith pull
```

Prefer changes only when you choose them? Pin to a released version:

```bash
git -C ~/.claude/skills/wikismith checkout v1.0.0
```

New releases appear on the [releases page](https://github.com/dougcallaway/wikismith/releases) with plain-language notes. To hear about them by email: **Watch → Custom → Releases** at the top of this page (needs a free GitHub account).
