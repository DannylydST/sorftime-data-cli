# GitHub Maintenance Checklist

Internal release checklist for maintaining the sorftime-cli repository. Run through this before every release.

## Before Every Release

- [ ] `bash scripts/doctor.sh --connect` passes (env + live API)
- [ ] If `resources/*.md` changed: run `bash scripts/gen-index.sh` and commit `resources/_endpoints-index.md`
- [ ] Description ≤ 350 chars, contains keywords (check: `gh repo view --json description`)
- [ ] Topics ≤ 20, relevant (check: `gh repo view --json repositoryTopics`)
- [ ] README.md: What's New section updated (latest date expanded, older dates folded in `<details>`)
- [ ] CHANGELOG.md: `[YYYY-MM-DD]` entry added (Added/Fixed/Changed)
- [ ] Wiki synced: new pages + `_Sidebar.md` + `Home.md` links
- [ ] Language audit: Wiki/README pure English; SKILL.md bilingual triggers; no internal process details in any public doc

## Common Mistakes

| Mistake | Fix |
|---------|------|
| Editing the wrong skill (sorftime-cli vs sorftime-seller-agent) | Both repos exist — check `git remote -v` before committing |
| Editing a doc but not the skill directory copy | `~/.claude/skills/sorftime-cli/` is the source; push from there |
| Forgetting to regenerate `_endpoints-index.md` | Run `bash scripts/gen-index.sh` after any resources change |
| Breaking the header format `# X Endpoints (N)` | gen-index.sh depends on it — keep the format when adding files |
| Internal process details leaking into public docs | README/CHANGELOG/Wiki: features and fixes only, no team/backup/release-process internals |

## npm Version Sync

When `sorftime-cli` on npm bumps:
1. Update the `sorftime-cli@X.Y.Z` reference in SKILL.md frontmatter + README header
2. Diff the new CLI's docs against `resources/` — regenerate what changed
3. Run `gen-index.sh` and commit the refreshed matrix
4. Update CHANGELOG.md with the endpoint/parameter changes
