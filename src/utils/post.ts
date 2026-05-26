import { getCollection } from 'astro:content'

export const getPosts = async (max?: number) =>
  (await getCollection('blog'))
    .sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf())
    .slice(0, max)

export const getTags = async () => {
  const posts = await getCollection('blog')
  const tagCounts: Map<string, number> = new Map()

  posts.forEach((post) => {
    post.data.tags.forEach((tag) => {
      const normalizedTag = tag.toLowerCase()
      tagCounts.set(normalizedTag, (tagCounts.get(normalizedTag) || 0) + 1)
    })
  })

  return Array.from(tagCounts.entries())
    .sort((a, b) => b[1] - a[1])
    .map(([name, count]) => ({ name, count }))
}

export const getPostByTag = async (tag: string) => {
  const posts = await getPosts()
  const lowercaseTag = tag.toLowerCase()

  return posts.filter((post) =>
    post.data.tags.some((postTag) => postTag.toLowerCase() === lowercaseTag),
  )
}
