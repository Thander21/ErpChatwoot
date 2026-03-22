# Security - ErpChatwoot

## 🔐 Variáveis de Ambiente e Segredos
- **.env**: NUNCA commite o arquivo `.env`. Utilize sempre o `.env.example` como guia.
- **Secrets**: Utilize variáveis de ambiente para tokens de API, chaves de criptografia e senhas de banco de dados.
- **JWT**: Garanta que as chaves de assinatura do JWT sejam mantidas seguras e rotacionadas periodicamente.

## 🛡️ Proteção de Dados
- **Sanitização**: Aplique sanitização rigorosa em qualquer dado vindo do usuário (HTML sanitization no frontend, Strong Params no backend).
- **Authorization**: Utilize o Pundit para garantir que os usuários só tenham acesso aos recursos autorizados.
- **PII**: Tome cuidado especial com dados sensíveis de clientes (Personal Identifiable Information). Logs não devem conter informações sensíveis.

## 🐳 Docker Security
- **Imagens**: Utilize imagens oficiais e mantenha-as atualizadas para evitar vulnerabilidades conhecidas.
- **Privilégios**: Evite rodar processos como `root` dentro dos containers sempre que possível.
