# Support

## Getting Started

- **Install**: `npm install -g sorftime-cli`
- **API key**: Get your Account-SK from the [Sorftime Pro dashboard](https://www.sorftime.com) → configure with `sorftime add <profile-name> <api-key>`
- **Self-check**: `bash scripts/doctor.sh --connect` verifies install, profile, and live connectivity in one command

## Documentation

- **[README.md](README.md)** — Quick start, helper scripts, field pitfalls, batch operations
- **[SKILL.md](SKILL.md)** — Full skill reference: endpoint catalog, shortcut map, parameter traps, recipes
- **[Wiki](https://github.com/DannylydST/sorftime-cli/wiki)** — Quickstart, scripts, trigger evaluation set

## FAQ

**Q: `sorftime: command not found`?**
Run `npm install -g sorftime-cli`. Requires Node.js 16+.

**Q: `sorftime api` returns an error code like `10`?**
Error codes are documented in `resources/_common.md` §6. Quick lookup: `bash scripts/decode.sh 10`.

**Q: A field I expected (e.g. `price`, `monthly sales`) is missing from the response?**
Check `resources/_field_aliases.md` first — Sorftime field names are non-standard (`SalesPrice`, `ListingSalesVolumeOfMonth`, `Ratings`). Don't conclude the endpoint doesn't return the data.

**Q: Batch requests fail with rate-limit errors (code 500/501/694)?**
Use `bash scripts/batch.sh` — it defaults to 1s between requests and supports retries (`--retries`) and resume (`--resume`).

**Q: Can I use this without an AI agent?**
Yes — the CLI and all helper scripts work standalone in any terminal.
