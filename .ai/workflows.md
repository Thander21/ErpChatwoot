# Workflows - ErpChatwoot

## 🎯 Princípios Gerais
- Toda mudança deve respeitar a [Arquitetura Overlay](file:///home/thander/Projetos/ErpChatwoot/.ai/rules/tech-stack.md).
- Verifique sempre o [File Registry](file:///home/thander/Projetos/ErpChatwoot/.ai/file-registry.md) antes de começar.
- **Isolamento**: Todo e qualquer comando de validação ou limpeza deve ser executado **EXCLUSIVAMENTE** contra o diretório `MenuPdvDmais/`.
- **Nota de Ambiente**: Comandos de validação (lint/test) exigem `RAILS_ENV=development`. Se estiver em produção, use `docker compose -f docker-compose-dev.yaml` ou instale as dependências.

---

## 📝 Workflow 1: Nova Funcionalidade Enterprise
**Trigger**: Usuário solicita recurso inexistente ou novo módulo.

### Passos:
1. **Identificar Domínio**: Decidir em qual pasta de `MenuPdvDmais/enterprise/` o código deve ficar.
// turbo
2. **Criar Estrutura**: Criar subpastas necessárias para Models, Controllers ou Composable.
3. **Draft de Código**: Implementar lógica inicial seguindo o [Coding Style](file:///home/thander/Projetos/ErpChatwoot/.ai/rules/coding-style.md).
4. **Registrar**: Adicionar novos arquivos em `.ai/file-registry.md`.

### Verificação:
- [/] Arquivos estão em `MenuPdvDmais/`?
- [/] Há migrações necessárias? (Ver Workflow 3)

---

## 🔧 Workflow 2: Patch de Arquivo do Core
**Trigger**: Necessidade de alterar código que reside apenas em `chatwoot-base/`.

### Passos:
// turbo
1. **Mock Patch**: Criar estrutura de diretórios em `MenuPdvDmais/core-patches/` idêntica ao original.
// turbo
2. **Copiar Base**: `cp chatwoot-base/[PATH] MenuPdvDmais/core-patches/[PATH]`.
3. **Modificar**: Aplicar as alterações no arquivo de `core-patches/`.
4. **Header**: Adicionar comentário `# PATCH ErpChatwoot: [DESCRIÇÃO]` no topo do arquivo.
5. **Update Registry**: Adicionar a correlação no [File Registry](file:///home/thander/Projetos/ErpChatwoot/.ai/file-registry.md).

---

## 💾 Workflow 3: Migração de Banco de Dados
**Trigger**: Alteração de schema ou criação de tabelas.

### Passos:
// turbo
1. **Gerar**: Criar arquivo em `MenuPdvDmais/db/migrate/` com timestamp atual.
2. **Implementar**: Escrever métodos `up`/`down` ou `change`.
// turbo
3. **Executar**: `docker compose -f docker-compose-dev.yaml exec rails bundle exec rails db:migrate`.
4. **Status**: Validar com `bundle exec rails db:migrate:status`.

---
  
## 🎨 Workflow Padrões Vue.js (MenuPdvDmais)
**Objetivo**: Maximizar a reutilização e manter a performance no frontend customizado.

### Regras de Reutilização em Vue:
1. **Lógica de Negócio (Composables)**: Extraia lógica repetitiva de estado/API para `composables/` (ex: `useDeployment.js`). Isso garante que componentes permaneçam focados apenas em apresentação.
2. **Componentes Genéricos (Slots/Props)**: Se três ou mais componentes compartilham o mesmo esqueleto (como as abas da Ficha), construa um **Componente Base** (Wrapper) que forneça a estrutura, aceitando os conteúdos iterativos e formulários específicos dinamicamente usando `<slot>`.
3. **Limpeza Funcional**: Evite duplicação de modais. Prefira injetar a interface diretamente no contexto onde será usada, emitindo os objetos completos (emits) de volta para o componente pai orquestrar as mutações.

---

## 🧪 Workflow 4: Ciclo de Validação Local
**Trigger**: Pré-commit ou pós-implementação de funcionalidade.

### Passos:
// turbo
1. **Rebuild**: `docker-compose down && docker-compose up --build -d` (Obrigatório: não usamos volumes para sincronizar código).
2. **Logs**: Monitorar em tempo real: `docker-compose logs -f app`.
3. **Teste Manual**: Acessar `localhost:3000` e validar o fluxo principal (Happy Path).
4. **Validar Código**: Executar o [Workflow 5: Validação Pré-Commit](#-workflow-5-validação-pré-commit).
5. **Console**: Entrar no container para validar estado do banco: `docker compose -f docker-compose-dev.yaml exec rails bundle exec rails console`.

---

## 🛑 Workflow 5: Validação Pré-Commit (Exclusiva MenuPdvDmais)
**Trigger**: Antes de realizar o `git commit`.

### Passos:
// turbo
1. **Lint Backend (Ruby)**: `docker compose -f docker-compose-dev.yaml exec rails bundle exec rubocop -A MenuPdvDmais/` (Auto-correct restrito ao código custom).
2. **Lint Frontend (JS/Vue)**: *(No Host OS)* `cd chatwoot-base && pnpm i --ignore-scripts && pnpm exec eslint --config .eslintrc.js --resolve-plugins-relative-to . --ext .js,.vue ../MenuPdvDmais/enterprise/app/javascript/ --fix`
// turbo
3. **Tests Backend (RSpec)**: `docker compose -f docker-compose-dev.yaml exec rails bundle exec rspec MenuPdvDmais/`.
4. **Tests Frontend (Vitest)**: *(No Host OS)* `cd chatwoot-base && pnpm i --ignore-scripts && pnpm run test ../MenuPdvDmais/enterprise/app/javascript/` (Localmente no Host).


### Verificação:
- [ ] ZERO erros de linting.
- [ ] Todos os testes passando (Verde).

---

## 🧹 Workflow 6: Auditoria, Validação Estática e Limpeza
**Trigger**: Mensalmente ou pós-refatorações estruturais (como a unificação da Ficha).

### Ferramentas e Comandos Recomendados:
1. **Knip (JavaScript/Vue)**: O Knip é ideal para detectar arquivos órfãos sem referências.
2. **Ruby (Unused Code)**: `docker compose -f docker-compose-dev.yaml exec rails bundle exec unused | grep MenuPdvDmais`
3. **Segurança Brakeman**: `docker compose -f docker-compose-dev.yaml exec rails bundle exec brakeman -p MenuPdvDmais/`

### Passos de Validação Estática (Host Layer):
// turbo
1. **Varredura de JS Órfãos**: `cd MenuPdvDmais && npx knip`
// turbo
2. **Lint Isolado (Vue/JS)**: `cd MenuPdvDmais && npx eslint --ext .js,.vue enterprise/app/javascript/ --fix`
// turbo
3. **Lint Backend (Docker)**: `docker compose -f docker-compose-dev.yaml exec rails bundle exec rubocop -A MenuPdvDmais/`

### Passos da Limpeza:
1. **Identificar**: Rodar os comandos acima e localizar arquivos não cobertos.
2. **Remover Código Morto Manualmente**: Deletar do repositório componentes não listados no entrypoint.
3. **Validação**: Subir a infra local e garantir que não quebrou dependências.

---

## ✅ Checklist Final de Tarefa
Antes de encerrar, a IA deve garantir:
- [ ] Nenhum arquivo em `chatwoot-base/` foi modificado.
- [ ] Todos os novos arquivos e patches estão no `file-registry.md`.
- [ ] Validações do [Workflow 5](#-workflow-5-validação-pré-commit) executadas e aprovadas.
- [ ] Mensagem de commit segue o padrão `feat:`, `fix:`, `docs:`, etc.
- [ ] Segredos (.env) não foram incluídos.
 em `MenuPdvDmais/`, nunca em `chatwoot-base/`
- [ ] `.env` não foi commitado
- [ ] Mensagem de commit segue Conventional Commits
