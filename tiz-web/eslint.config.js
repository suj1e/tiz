import antfu from '@antfu/eslint-config'

export default antfu({
  react: true,
  typescript: true,
  formatters: {
    css: true,
  },
  rules: {
    'react-refresh/only-export-components': 'off',
    'ts/no-empty-object-type': 'off',
  },
})
