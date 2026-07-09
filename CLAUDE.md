# popov.github.io

Personal blog built with [Zola](https://www.getzola.org/) using the `terminus` theme.

## Build workflow

- Site content (Markdown) lives in `content/`.
- Static assets (images, etc.) go in `static/` — e.g. images for a post go in `static/images/<post_slug>/`.
- Running `zola build` renders the site into `docs/` (the GitHub Pages publish directory), and copies everything from `static/` into `docs/` as well (e.g. `static/images/introducing_pomelo/*` → `docs/images/introducing_pomelo/*`).
- `docs/` is generated output — don't hand-edit files under `docs/` directly; edit `content/` (and `static/`) and re-run `zola build`.
- `base_url` in `zola.toml` is `https://ron-popov.github.io/popov.github.io`, so built pages reference absolute URLs under that prefix.
