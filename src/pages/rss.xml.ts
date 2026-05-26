import rss from '@astrojs/rss'
import { getCollection } from 'astro:content'
import { siteConfig } from '@/site-config'
import type { APIContext } from 'astro'

export const GET = async (context: APIContext) => {
  const posts = await getCollection('blog')
  
  // Sort posts by date (newest first)
  const sortedPosts = posts.sort((a, b) => 
    new Date(b.data.pubDate).getTime() - new Date(a.data.pubDate).getTime()
  )

  return rss({
    title: siteConfig.title,
    description: siteConfig.description,
    site: context.site?.toString() || 'https://easy-personal-finance.com',
    items: sortedPosts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: new Date(post.data.pubDate),
      link: `/post/${post.id}/`,
      categories: post.data.tags,
    })),
    customData: `<language>${siteConfig.lang}</language>`,
  })
}
