# Contributing to Sorftime Data CLI Skill

Thanks for your interest in contributing.

## Ways to Contribute

- **Report bugs** — Open an issue with the endpoint, parameters, and the exact error code
- **Suggest features** — Tell us which automation workflow you want enabled (batch, monitoring, orchestration)
- **Improve docs** — Fix typos, add examples, translate
- **Submit PRs** — Bug fixes, new endpoint docs, new helper scripts
- **Share use cases** — Real batch/monitoring workflows help us prioritize

## Getting Started

```bash
git clone https://github.com/DannylydST/sorftime-cli.git
cd sorftime-cli
npm install -g sorftime-cli     # Install the CLI itself
sorftime add myprofile <api-key>  # Configure your profile (token from Sorftime dashboard (open-intl.sorftime.com))
bash scripts/doctor.sh          # Verify everything works
```

## Project Layout

```
sorftime-cli/
├── SKILL.md          # Main index + discovery path + endpoint catalog
├── README.md         # Human quick reference
├── resources/        # Per-platform endpoint reference docs
├── scripts/          # Helper scripts (call/one/batch/doctor/decode/gen-index/_lib)
└── trigger-eval.json # Trigger evaluation set (bilingual)
```

## Before Submitting

- [ ] Run `bash scripts/doctor.sh --connect` — environment and live API both pass
- [ ] If you touched `resources/*.md`, run `bash scripts/gen-index.sh` and commit the regenerated `resources/_endpoints-index.md`
- [ ] If you discovered an API quirk (parameter casing, field naming, error code), add it to the Parameter Naming Traps table in `SKILL.md` and `resources/_field_aliases.md`
- [ ] Update `CHANGELOG.md` under today's `[YYYY-MM-DD]` section (Added/Fixed/Changed)

## Style Notes

- Scripts are POSIX bash 4+, source `scripts/_lib.sh` for shared helpers
- Endpoint docs: one section per endpoint, keep the header format `# X Endpoints (N)` (gen-index.sh depends on it)
- All user-facing docs in English; the skill's replies follow the user's language
