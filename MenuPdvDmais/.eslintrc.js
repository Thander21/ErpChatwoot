module.exports = {
  extends: ["plugin:vue/vue3-recommended", "eslint:recommended"],
  env: {
    browser: true,
    es2021: true,
  },
  parserOptions: {
    ecmaVersion: 12,
    sourceType: "module",
  },
  rules: {
    // Ignora importações do chatwoot-base para remover falso-positivos de módulo não resolvido localmente
    // Em produção/build real isso não é problema, já que é compilado via alias no webpack/vite
    "import/no-unresolved": "off",
    "import/extensions": "off",
    "vue/no-unused-components": "warn",
    "no-unused-vars": "warn",
    "no-console": "warn",
    "vue/multi-word-component-names": "off"
  },
};
