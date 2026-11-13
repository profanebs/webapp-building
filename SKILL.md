---
name: webapp-building
description: Tools for building modern React webapps with TypeScript, Tailwind CSS and shadcn/ui on the local machine. Best suited for applications with complex UI components and state management. If the user mentions building a website, webpage, or app, you MUST read and follow this skill's guidance to deploy a local React project rather than a plain HTML file. Supports optional templates for specialized requirements. Local edition.
---

# WebApp Building — local edition

**Stack**: React + TypeScript + Vite + Tailwind CSS + shadcn/ui

This is the local edition of the `webapp-building` skill (based on the online v5 version), adapted to run on your PC instead of inside the cloud VM:

| | online (VM) | local (this skill) |
|---|---|---|
| Project path | fixed `/mnt/agents/output/app` | explicit `<project-dir>` you pass to the script |
| Dependencies | pre-baked `node_modules` copied from the image | `npm install` from the public registry |
| Registration | registers the app with the VM portal at `localhost:8080` | none — output is plain local files |
| Preview | platform-hosted | `npm run dev` / `npm run preview` on localhost |
| Deploy | handled by the platform | not handled — `dist/` is a plain static site |

## Requirements

- Node.js 20+ and npm (check with `node --version`)
- `python3` and `unzip`

## Workflow

1. `bash <skill-dir>/scripts/init-webapp.sh <project-dir> "<website-title>" [template-name] [--no-install]` — initialize the project in a directory of your choice
   - Without template-name: creates the base project (0-origin) with 40+ shadcn/ui components
   - With template-name: applies a specialized template and prints template-specific configuration notes
   - `--list` shows all available templates
2. Read `template-info.md` in the generated project and follow its instructions
3. Edit source code in `src/` (or `src/config.ts` for templates)
4. Run / build / preview locally (see below)
5. Pass the design gate (see "Design gate" below)
6. Deliver a local preview (see below)

## Quick Start

### 1. Initialize

```bash
# <skill-dir> is the directory containing this SKILL.md,
# e.g. ~/.config/opencode/skills/webapp-building
bash <skill-dir>/scripts/init-webapp.sh ./app "My Website"
cd ./app
```

**Agent notes**:
- You choose the project directory. A reasonable default is `./app` under the current working directory, or a path the user gives you.
- The script refuses to write into a non-empty directory.
- Dependencies are installed with `npm install --no-audit --no-fund` (requires network). If the shell tool is sensitive to long-running subprocesses, use `--no-install` and run `npm install` yourself afterwards.
- On success the script prints the template's `info.md`; it is also saved as `template-info.md` in the project root. Read it before editing.

This creates a fully configured project with:

- ✅ React + TypeScript (via Vite)
- ✅ Tailwind CSS 3.4.19 with shadcn/ui theming system
- ✅ Path aliases (`@/`) configured
- ✅ 40+ shadcn/ui components pre-installed
- ✅ All Radix UI dependencies included
- ✅ Production build optimization with Vite

### 2. Develop

Edit generated files in `src/`: page sections go in `src/sections/`, custom React hooks in `src/hooks/`, and TypeScript definitions in `src/types/`.

For templates: edit `src/config.ts` to customize content. Do not modify component files — all content configuration is in config.ts.

### 3. Run / Build / Preview

```bash
npm run dev       # dev server with HMR at http://localhost:3000
npm run build     # production build → dist/
npm run preview   # serve the production build locally
```

**Agent notes**:
- The dev server port defaults to **3000** (hardcoded in `vite.config.ts`). Before starting `npm run dev`, scan which ports are already in use (e.g. `lsof -iTCP -sTCP:LISTEN -P -n`) and pick a free one — never let a new project take over the port of an older project that is still running. Use a different port via `npm run dev -- --port <N>` (or edit `port` in `vite.config.ts`).

**Output** (`dist/`):
- `index.html` — Entry point
- `assets/index-[hash].js` — Bundled JS
- `assets/index-[hash].css` — Bundled CSS
- Optimized images, fonts, other assets

**Optimizations**: Tree-shaking, code splitting, asset compression, minification, cache-busting hashes.

Deployment is up to you: `dist/` is a plain static site that works on Vercel / Netlify / GitHub Pages / any static host. This skill does not deploy.

### 4. Deliver: local preview

When the site is ready:

1. Pick a free port and start the dev server: `npm run dev -- --port <N>`. Never let a new project take over the port of an older project that is still running.
2. Validate with `npm run build` and any project tests.
3. In the final response, include the local URL `http://localhost:<N>/` and the absolute project root directory.

Do not use a `file://` URL or a temporary build artifact URL.

## Pre-delivery checks

界面做完、`npm run build` 过了之后，交付前至少过一遍：

- [ ] 桌面宽度和窄屏各看一次渲染结果，别只读代码
- [ ] 空状态、超长文本、加载中、错误态都有交代
- [ ] 对比度、键盘可达、`prefers-reduced-motion` 没过界
- [ ] 同层级元素的对齐、间距、圆角、阴影同源
- [ ] 装过 `frontend-design` 技能的话，按它的 critique / audit 两步各过一遍

它只查下限，不查审美上限；检测通过不等于设计好。


## Templates

`bash <skill-dir>/scripts/init-webapp.sh --list` prints all 25 bundled templates. Two families:

- `0-origin` + the `*-style` series — classic single-page templates
- the numbered series (`1-` … `12-`) — newer, highly designed templates

⚠️ **Fullstack templates** (`9-moon-note-fullstack`, `10-calm-space-fullstack`, `11-my-blog-fullstack`, `12-seaside-stay-fullstack`) ship `api/`, `db/` and `contracts/` directories and were designed for the original online runtime (tRPC + Drizzle + Hono + MySQL + OAuth). Locally you can still scaffold them, but the server side will not work out of the box — expect to adapt or stub it yourself. Prefer the frontend templates unless the user explicitly asks for a fullstack project.

## Debugging

1. Fix source files
2. `npm run build`
3. Test `dist/` with `npm run preview`

## Reference

- [shadcn/ui Components](https://ui.shadcn.com/docs/components)
