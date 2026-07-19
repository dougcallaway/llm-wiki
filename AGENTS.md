# AGENTS.md — working on wikismith

This repository *is* an Agent Skill: `SKILL.md` is the product (instructions the user's agent follows), `README.md` and the `setup-*.md` guides are for human readers. This file is for agents and contributors editing the repo itself. (If you were looking for your wiki's rules, this isn't it — a wiki's own conventions live in its `schema.md`.)

## Writing rules

- **Clarity bar:** every user-facing document must be understandable to a reader with a high-school background who has never used a terminal. Explain or link jargon at first use.
- **Cite at the point of use.** Every borrowed idea gets a name and a link where it's used (Wikipedia-style linked sources), plus a TASL entry (Title, Author, Source, License) in the README's Credits. Factual claims about other products link a source.
- **Trademark care:** "Building a Second Brain," "BASB," and "PARA" are Forte Labs marks — descriptive use only, never in names or taglines; keep the README's non-affiliation disclaimer intact.
- **Vocabulary:** the skill is written for "the agent" — any Agent Skills tool. Claude Code appears only as the tested reference or as one agent's example (always alongside "other agents have their own equivalents"), never as a requirement. The user owns the wiki; the agent *maintains* it. Express produces starting drafts the user finishes. The folder and its items are "capture"/"captures," never "inbox" in prose — trigger phrases quoting what users actually say are exempt.

## Release rules

- The 1.0 stability promise binds: the page format and the never-edited capture directory don't change in minor versions; a breaking change means a major version *and* a migration the agent performs — users never restructure their wiki by hand.
- Tag every release (`vX.Y.Z`), publish plain-language notes on the GitHub release, and keep the README's pin example current.
- Code files carry `SPDX-License-Identifier` headers; text files are LF (enforced by `.gitattributes`).
