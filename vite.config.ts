import { defineConfig } from 'vite'
import rubyPkg from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue'

// `vite-plugin-ruby` may be published in different module shapes depending
// on bundler/Node resolution (CommonJS function export, an object with
// `rubyPlugin`, or a `default` wrapper). Normalize to a callable.
const rubyPlugin = (() => {
  const p: any = rubyPkg
  if (typeof p === 'function') return p
  if (p && typeof p.rubyPlugin === 'function') return p.rubyPlugin
  if (p && p.default && typeof p.default === 'function') return p.default
  if (p && p.default && typeof p.default.rubyPlugin === 'function') return p.default.rubyPlugin
  throw new Error('Could not locate rubyPlugin export from vite-plugin-ruby')
})()

// Call the plugin factory and ensure we flatten the result if it returns
// an array of plugins (some plugin factories return multiple plugin objects).
const rubyPlugins = (() => {
  const result = (rubyPlugin as any)()
  return Array.isArray(result) ? result : [result]
})()

export default defineConfig({
  plugins: [
    ...rubyPlugins,
    vue(),
  ],
})
