/**
 * Rehype plugin to add lazy loading to images
 */
export function lazyLoadImages() {
  return (tree) => {
    const visit = (node) => {
      if (node.type === 'element' && node.tagName === 'img') {
        // Add loading="lazy" if not already present
        if (!node.properties.loading) {
          node.properties.loading = 'lazy'
        }
        // Add decoding="async" for better performance
        if (!node.properties.decoding) {
          node.properties.decoding = 'async'
        }
        // Add error handler for broken images
        if (!node.properties.onerror) {
          node.properties.onerror = "this.style.display='none'"
        }
      }
      
      // Recursively visit children
      if (node.children && Array.isArray(node.children)) {
        node.children.forEach(visit)
      }
    }
    
    visit(tree)
  }
}
