# Performance - ErpChatwoot

## 🚀 Backend Optimization
- **Database Indexing**: Certifique-se de que colunas usadas em filtros ou joins possuam índices adequados no PostgreSQL.
- **N+1 Queries**: Utilize `includes`, `preload` ou `eager_load` no Active Record para evitar problemas de N+1.
- **Caching**: Utilize o Redis para cache de fragmentos de página ou resultados de queries pesadas.
- **Background Jobs**: Mova tarefas demoradas (envio de email, parse de arquivos grandes) para o Sidekiq.

## 🎨 Frontend Optimization
- **Vite Build**: Utilize as facilidades de otimização do Vite (code splitting, tree shaking).
- **Lazy Loading**: Utilize lazy loading para rotas e componentes pesados.
- **Asset Compression**: Certifique-se de que imagens e outros assets sejam otimizados antes de serem servidos.

## 🤖 AI Usage Optimization
- **Token Efficiency**: Seja conciso em interações com modelos de linguagem.
- **Prompt Engineering**: Forneça contexto claro (arquivos relevantes) para evitar alucinações e retrabalho.
