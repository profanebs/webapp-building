# webapp-building

A skill for building modern React webapps locally: React + TypeScript + Vite + Tailwind CSS + shadcn/ui.

It ships a scaffolder and 25 templates, so the agent starts from a working project instead of a blank folder. This is the local edition of the `webapp-building` skill, adapted from the online VM version: the project directory is an explicit argument, dependencies come from the public npm registry, and the output is a plain local project.

## What it does

- Scaffolds a React + TypeScript project with Tailwind 3.4 and 40+ shadcn/ui components pre-installed.
- Applies one of 25 bundled templates (classic single-page and highly designed variants).
- Runs dev / build / preview locally.
- Adds a pre-delivery checklist covering empty states, long text, narrow screens, contrast, and keyboard access.
- Does not deploy. `dist/` is a plain static site.

## Requirements

- Node.js 20+ and npm
- `bash`, `python3`, and `unzip` (Git Bash works on Windows)

## Usage

```bash
# List templates
bash <skill-dir>/scripts/init-webapp.sh --list

# Create a base project
bash <skill-dir>/scripts/init-webapp.sh ./app "My Website"

# Create from a template
bash <skill-dir>/scripts/init-webapp.sh ./app "My Website" 12-seaside-stay-fullstack
```

Then read `template-info.md` in the generated project, edit `src/` (or `src/config.ts` for templates), and run:

```bash
npm run dev       # dev server at http://localhost:3000
npm run build     # production build to dist/
npm run preview   # serve the production build
```

## Templates

Two families:

- `0-origin` plus the `*-style` series — classic single-page templates.
- The numbered series (`1-` … `12-`) — newer, highly designed templates.

The fullstack templates (`9-moon-note-fullstack`, `10-calm-space-fullstack`, `11-my-blog-fullstack`, `12-seaside-stay-fullstack`) include `api/`, `db/`, and `contracts/` directories and were designed for the original online runtime. Locally you can scaffold them, but the server side (database, OAuth) will not work out of the box. Prefer the frontend templates unless you explicitly need a fullstack project.

## Install

Copy this directory into your agent's skills directory:

```powershell
# Windows
Copy-Item -Recurse webapp-building "$env:USERPROFILE\.config\opencode\skills\"

# macOS / Linux
cp -r webapp-building ~/.config/opencode/skills/
```

## Credits

Based on the online v5 version of the `webapp-building` skill. The upstream author was not stated in the source material; the local adaptations (explicit project directory, local npm install, no portal registration, pre-delivery checklist) are maintained by the webapp-building contributors.

## License

MIT. See `LICENSE`.
