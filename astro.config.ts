// @ts-check
import { defineConfig } from 'astro/config'
import mdx from '@astrojs/mdx'
import sitemap from '@astrojs/sitemap'
import pagefind from 'astro-pagefind'
import { remarkReadingTime } from './src/utils/readTime'
import { lazyLoadImages } from './src/plugins/lazyLoadImages.mjs'
import tailwindcss from '@tailwindcss/vite'

// https://astro.build/config
export default defineConfig({
  site: 'https://51685188.xyz',

  devToolbar: {
    enabled: false,
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  markdown: {
    remarkPlugins: [remarkReadingTime],
    rehypePlugins: [lazyLoadImages],
    shikiConfig: {
      theme: 'github-dark',
      wrap: true,
    },
  },

  integrations: [
    mdx(),
    pagefind(),

    sitemap({
      i18n: {
        defaultLocale: 'en',
        locales: {
          en: 'en',
        },
      },
    }),
  ],

  vite: {
    plugins: [tailwindcss()],
  },
})
