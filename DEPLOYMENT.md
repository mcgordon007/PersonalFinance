# AiToolPulse — Deployment Guide

## Project Overview

AiToolPulse is an English-language AI tools blog built with **Astro** and the **nano-blog** theme, designed for deployment on **Cloudflare Pages**.

## Local Development

### Prerequisites
- **Node.js** v22+ (LTS recommended)
- **pnpm** v10+ (recommended) or npm

### Setup

```bash
# Navigate to the project
cd AiToolPulse

# Install dependencies
pnpm install
# OR: npm install --legacy-peer-deps

# Start development server
pnpm start
# OR: npm run start
```

The dev server will run at `http://localhost:4321`

### Build

```bash
pnpm build
# OR: npm run build
```

Output will be in the `dist/` directory.

### Preview Production Build

```bash
pnpm preview
# OR: npm run preview
```

---

## Deploy to Cloudflare Pages

### Option 1: Connect GitHub Repository (Recommended)

1. **Push to GitHub**
   ```bash
   # Initialize git (if not already)
   git init
   git add .
   git commit -m "Initial commit: AiToolPulse blog"
   git remote add origin https://github.com/YOUR_USERNAME/AiToolPulse.git
   git branch -M main
   git push -u origin main
   ```

2. **Connect to Cloudflare Pages**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Navigate to **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
   - Select your `AiToolPulse` repository
   - Configure build settings:
     - **Framework preset:** `None`
     - **Build command:** `pnpm build` (or `npm run build`)
     - **Build output directory:** `dist`
   - Add environment variable:
     - `NODE_VERSION` = `22`
   - Click **Save and Deploy**

3. **Custom Domain (Optional)**
   - In Cloudflare Pages → your project → **Custom domains**
   - Add your domain (e.g., `aitoolpulse.com`)
   - Update DNS records as instructed

### Option 2: Direct Upload (Wrangler CLI)

```bash
# Install Wrangler
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Build the project
pnpm build

# Deploy
wrangler pages deploy dist --project-name=aitoolpulse
```

---

## Project Structure

```
AiToolPulse/
├── astro.config.ts          # Astro configuration (site URL, i18n, plugins)
├── package.json             # Dependencies and scripts
├── public/
│   ├── favicon.ico          # Site favicon
│   ├── robots.txt           # SEO robots configuration
│   └── fonts/               # Manrope font files
├── src/
│   ├── site/
│   │   └── site.config.ts   # Site metadata (title, description, author)
│   ├── i18n/
│   │   ├── en.json          # English UI translations
│   │   └── ui.ts            # Language configuration
│   ├── components/          # Astro components (Header, Footer, etc.)
│   ├── data/
│   │   └── blog/            # Blog posts (Markdown/MDX)
│   │       └── 2025/
│   ├── layouts/             # Page layouts
│   ├── pages/               # Routes (Home, About, Tags, Post)
│   └── styles/              # Global CSS (Tailwind)
```

## Writing New Blog Posts

Create a new `.mdx` file in `src/data/blog/YYYY/YYYY-MM-DD/post-slug/index.mdx`:

```mdx
---
title: 'Your Post Title'
description: 'A brief description for SEO and previews'
pubDate: '2025-05-20'
heroImage: ''  # Optional: path to hero image
tags: ['AI Tools', 'Review']
---

Your content here...
```

## Customization

- **Site info:** `src/site/site.config.ts`
- **UI text:** `src/i18n/en.json`
- **SEO:** `astro.config.ts` (site URL, sitemap)
- **Styles:** `src/styles/global.css` (Tailwind CSS)
- **Favicon:** Replace `public/favicon.ico`

## Tech Stack

- [Astro](https://astro.build/) v6 — Static Site Generator
- [TailwindCSS](https://tailwindcss.com/) v4 — Utility-first CSS
- [MDX](https://mdxjs.com/) — Markdown + JSX
- [Pagefind](https://pagefind.app/) — Static search
- [Cloudflare Pages](https://pages.cloudflare.com/) — Hosting
