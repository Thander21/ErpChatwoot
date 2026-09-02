# Diretrizes de Extensão e Build: ErpChatwoot

## 1. Inicializadores e Namespaces Rails (Anti-NameError)
- Ao criar arquivos em `MenuPdvDmais/enterprise/config/initializers/` ou `MenuPdvDmais/config/initializers/`, **NUNCA** use o atalho de resolução de constante com dois pontos quando o namespace pai puder não estar em memória:
  ❌ Incorreto: `module Enterprise::MeuServico`
  ✅ Correto:
  ```ruby
  module Enterprise
    module MeuServico
      # código aqui
    end
  end
  ```
- Isso previne falhas de `NameError: uninitialized constant Enterprise` durante a fase inicial do `rails assets:precompile` no Docker.

## 2. Cópia Não Destrutiva de Pastas no Dockerfile
- Ao copiar pastas de customização que precisam mesclar arquivos com pastas já existentes no core (como `db/migrate`):
  ❌ Incorreto: `COPY MenuPdvDmais/db/migrate /app/db/migrate` (substitui a pasta inteira, apagando as migrações do upstream).
  ✅ Correto: `COPY MenuPdvDmais/db/migrate/. /app/db/migrate/` (adiciona os arquivos mantendo as migrações base intactas).

## 3. Atualizações de Upstream e Migrações
- Sempre que o upstream for atualizado com novas tabelas (ex: `user_sessions`), certifique-se de que `/app/db/migrate` contém a soma das migrações do base + customizadas.
- Se o banco de dados em desenvolvimento foi inicializado via `schema:load` e `rails db:migrate` tentar rodar `init_schema` (falhando com duplicate table), execute apenas as migrações pendentes específicas ou registre os timestamps prévios em `schema_migrations`.
