# llm-wiki

**A knowledge base your AI agent builds and maintains for you — plain markdown files that get richer every time you add a source.**

You drop in articles, notes, and links. Your agent reads them, files the knowledge into interlinked pages, flags where new sources contradict old ones, and keeps an index so nothing gets lost. Instead of re-reading the same documents every time you have a question, you ask the wiki — and it answers from everything you've ever fed it.

It's an [Agent Skill](https://code.claude.com/docs/en/skills) (the open `SKILL.md` standard), so it works with any AI coding agent that can read and write files in a folder. Claude Code is the tested reference; Codex, Gemini CLI, Cursor, and other Agent Skills–compatible tools should work too (reports welcome — see [Compatibility](#compatibility)).

## What you get

- **One knowledge base that compounds.** Every source you add updates existing pages, adds cross-references, and gets logged. The wiki is worth more after the tenth source than the sum of ten separate notes.
- **Answers, not searches.** Ask "what do I know about X" and get a synthesis with links to the pages behind it — not a pile of documents to re-read.
- **Plain markdown you own.** No database, no lock-in. The whole wiki is folders of `.md` files you can read, edit, back up, or open in any markdown app.
- **Frictionless capture.** Toss things into `capture/` without processing. They wait there until you ask to organize them.

## How it works

Two ideas do the work.

**Karpathy's LLM Wiki pattern.** Rather than re-deriving answers from raw documents every time (the usual "retrieval" approach), your agent builds and maintains a *persistent wiki*: structured, interlinked markdown pages that improve with every source. Integrating a source updates the pages it touches, flags contradictions, and adds cross-references.

**Forte's CODE method** maps onto four operations:

| CODE step | Operation | What your agent does |
|-----------|-----------|-----------------|
| **C**apture | `capture` | Drop ideas and links into `capture/` without processing |
| **O**rganize | `organize` | Integrate captures into the wiki; update the pages they touch |
| **D**istill | `distill` | Progressively compress pages to their essential insights |
| **E**xpress | `express` | Produce a finished artifact — a draft, report, or decision doc |

Three utility operations sit outside CODE: `query` (retrieve and synthesize from the wiki), `calibrate` (learn your writing voice so `express` outputs sound like you), and `lint` (health-check for orphan pages, contradictions, and dead links).

Your job: capture, direct, and express. The agent's job: everything else.

## schema.md — your wiki's schema

Each wiki has a `schema.md` at its root that the agent reads at the start of every session. It defines the domain, page types, organizing conventions, and tag vocabulary for that specific wiki. When you initialize a new wiki, the agent creates a sensible default — refine it together as you learn what works for your domain.

> Wikis created with an earlier version used `CLAUDE.md` for this file. Those still work: the skill reads `schema.md` if present and falls back to `CLAUDE.md`. Rename it to `schema.md` when convenient so any agent, not just Claude, treats it as an ordinary file.

## Design principles

- **Capture is frictionless.** `capture/` is a holding area, not the wiki. Drop things in without processing; they sit there until you ask to organize them.
- **Cross-references compound value.** A page with no inbound links is nearly invisible. Be thorough on connections, not just summaries.
- **Distillation is lossy by design.** The goal is resonance, not completeness — keep what you'd want to rediscover six months from now.
- **Outputs are first-class wiki citizens.** A good draft or analysis belongs in the knowledge base, not just in chat history.
- **Voice is for outputs only.** `calibrate` teaches your agent your writing voice and `express` applies it — but internal pages stay in a neutral reference voice, so the knowledge base stays a clean substrate.

## Install

**Claude Code** — clone into your personal skills directory:

```bash
git clone https://github.com/dougcallaway/llm-wiki ~/.claude/skills/llm-wiki
```

The skill is then available as `/llm-wiki` in any Claude Code session.

**Other agents** — Codex, Gemini CLI, Cursor, and other tools that support the `SKILL.md` standard load skills from their own skills directory. Clone this repo there (check your tool's skills documentation for the exact path). Everything the skill does is plain file reading and writing, so no Claude-specific features are required.

## Compatibility

The wiki is just markdown files and folders, so it opens in Obsidian, VS Code, or any markdown editor. Two conventions keep it portable and future-proof:

- **Use relative markdown links** — `[Concept](../resources/concept.md)` — as the default for connections between pages. They resolve the same in every tool. `[[wikilinks]]` work if you view the wiki in Obsidian, but they aren't part of standard Markdown, so prefer relative links for anything you want other tools to read as a connection.
- **Folders are the hierarchy, and a page's path is its identity.** Renaming or moving a page means updating the links that point to it. The `lint` operation catches links left dangling.

### Works with Verdondo

llm-wiki's page format is the wiki format of **[Verdondo](https://github.com/verdondo)**, a visual knowledge tool in development that lets you view and edit a knowledge graph as naturally as drawing on a whiteboard. A wiki you build with this skill — relative-linked markdown pages with frontmatter — is meant to be readable by Verdondo as it matures. Verdondo keeps its own view data in a `.verdondo/` folder and `.canvas` sidecar files alongside your pages; the skill leaves those alone, and so should you.

## Credits

Built on the ideas of others, credited here in [TASL format](https://wiki.creativecommons.org/wiki/Best_practices_for_attribution) (Title, Author, Source, License):

- **The LLM Wiki pattern** — Andrej Karpathy — https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f — no license declared; the note explicitly invites adaptation. The idea of an AI agent maintaining a structured, interlinked knowledge base between you and raw sources.
- **The CODE method and the PARA method** — Tiago Forte (Forte Labs) — https://fortelabs.com/blog/the-4-levels-of-personal-knowledge-management/ and https://fortelabs.com/blog/para/ — © the author, referenced descriptively. CODE (Capture, Organize, Distill, Express) is the knowledge workflow this skill implements; PARA (Projects, Areas, Resources, Archives) is one organizing scheme the default schema supports.

> **Not affiliated with or endorsed by Forte Labs or Andrej Karpathy.** "Building a Second Brain," "BASB," and "PARA" are marks of Forte Labs; they are used here only to describe the methods this skill adapts.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, adapt it. Attribution is appreciated but not required.

## Version management

Pin to a released version:

```bash
git -C ~/.claude/skills/llm-wiki checkout v0.1.0
```

Update to the latest:

```bash
git -C ~/.claude/skills/llm-wiki checkout main && git -C ~/.claude/skills/llm-wiki pull
```
