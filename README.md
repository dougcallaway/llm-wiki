# llm-wiki

A Claude Code skill that maintains a persistent personal knowledge base using
[Karpathy's LLM Wiki pattern](https://karpathy.github.io/2023/11/13/llmwiki/) and
[Forte's CODE method](https://fortelabs.com/blog/the-4-levels-of-personal-knowledge-management/).

For full behavior documentation, see [SKILL.md](SKILL.md).

## Install

Clone directly into your Claude Code personal skills directory:

```bash
git clone https://github.com/YOUR_USERNAME/wiki ~/.claude/skills/llm-wiki
```

The skill is immediately available as `/llm-wiki` in any Claude Code session.

## Pin to a version

```bash
git -C ~/.claude/skills/llm-wiki checkout v1.0.0
```

## Update to latest

```bash
git -C ~/.claude/skills/llm-wiki pull
```

## Rollback

```bash
git -C ~/.claude/skills/llm-wiki checkout v1.0.0
```
