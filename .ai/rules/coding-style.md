# Coding Style - ErpChatwoot

## 🎨 Frontend (Vue.js)
- **Composition API**: Use sempre a Composition API do Vue 3.
- **SFC**: Utilize componentes Single File Components (.vue).
- **Scoped CSS**: Sempre que possível, utilize `<style scoped>` para evitar vazamento de estilos.
- **Nomenclatura**: PascalCase para nomes de arquivos de componentes. camelCase para pastas e outros arquivos JS.

## 💎 Backend (Ruby on Rails)
- **MVC Tradicional**: Respeite a estrutura de camadas do Rails.
- **Padrões de Nomenclatura**: Siga as convenções do Rails (snake_case para métodos e variáveis, CamelCase para classes).
- **Service Objects**: Para lógica de negócio complexa que não pertence ao model ou controller, considere o uso de Service Objects.

## 🗣️ Idiomas e Convenções
- **Código**: Nomes de variáveis, funções, classes e comentários técnicos devem ser em **INGLÊS**.
- **Commits**: Utilize **PORTUGUÊS (PT-BR)** e finalize com o padrão **Conventional Commits** (ex: `feat: adicionar suporte a...`).
- **Logs**: Mensagens de log em inglês para consistência com o core.

## 🛡️ Tratamento de Erros & Async
- **Async/Await**: Utilize `async/await` para operações assíncronas no frontend.
- **Sanitização**: Sempre valide inputs e sanitize outputs para evitar XSS e SQL Injection.
- **Exceptions**: Utilize blocos `begin/rescue` em Ruby para capturar exceções esperadas e logá-las adequadamente.
