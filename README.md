# llm-wiki

A Claude Code skill that maintains a persistent personal knowledge base using
[Karpathy's LLM Wiki pattern](https://karpathy.github.io/2023/11/13/llmwiki/) and
[Forte's CODE method](https://fortelabs.com/blog/the-4-levels-of-personal-knowledge-management/).

## How it works

**Karpathy's LLM Wiki** — instead of re-deriving answers from raw documents every time (RAG), Claude builds and maintains a *persistent wiki*: structured, interlinked markdown files that compound over time. Every source integrated updates entity pages, flags contradictions, and adds cross-references. Nothing gets lost.

**Forte's CODE method** maps onto four operations:

| CODE step | Operation | What Claude does |
|-----------|-----------|-----------------|
| **C**apture | `capture` | Drop ideas/links into `capture/` without processing |
| **O**rganize | `organize` | Integrate captures into the wiki; update entity and concept pages |
| **D**istill | `distill` | Progressively compress pages to their essential insights |
| **E**xpress | `express` | Produce a finished artifact — draft, report, or decision doc |

Two utility operations sit outside CODE: `query` (retrieve and synthesize from the wiki) and `lint` (health-check for orphans, contradictions, and dead links).

The user's job: capture, direct, and express. Claude's job: everything else.

For full behavior documentation, see [SKILL.md](SKILL.md).

## CLAUDE.md — your wiki's schema

Each wiki has a `CLAUDE.md` at its root that Claude reads on every session. It defines the domain, page types, organizing conventions, and tag vocabulary for that specific wiki. When you initialize a new wiki, Claude creates a sensible default — update it together as you discover what works for your domain.

## Design principles

- **Capture is frictionless.** `capture/` is a holding area, not the wiki. Drop things in without processing; they sit there until you ask to organize them.
- **Cross-references compound value.** A page with no inbound links is nearly invisible. Be thorough on connections, not just summaries.
- **Distillation is lossy by design.** The goal is resonance, not completeness — keep what you'd want to rediscover six months from now.
- **Outputs are first-class wiki citizens.** A good draft or analysis belongs in the knowledge base, not just in chat history.

## Install

Clone directly into your Claude Code personal skills directory:

```bash
git clone https://github.com/dougcallaway/llm-wiki ~/.claude/skills/llm-wiki
```

The skill is immediately available as `/llm-wiki` in any Claude Code session.

## Pin to a version

```bash
git -C ~/.claude/skills/llm-wiki checkout v0.1.0
```

## Update to latest

```bash
git -C ~/.claude/skills/llm-wiki pull
```

## Rollback

```bash
git -C ~/.claude/skills/llm-wiki checkout v0.1.0
```
