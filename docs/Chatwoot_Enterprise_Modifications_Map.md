# Mapeamento de Modificações do Chatwoot Enterprise (Menu PDV D+)

Este documento detalha **todas as alterações** aplicadas sobre o código original do [Chatwoot v4.11.0](https://github.com/chatwoot/chatwoot) pelo projeto ErpChatwoot (Enterprise / Menu PDV D+). 

O objetivo do nosso patch é **não alterar ou quebrar as páginas já existentes do Chatwoot** (como a aba de Contatos, Caixas de Entrada, etc), mas sim **injetar novas rotas, tabelas e menus** de forma paralela.

---

## 1. Arquivos Base Modificados (`core-patches/`)
Apenas um conjunto muito restrito de arquivos do ecosistema original do Chatwoot é sobrescrito, unicamente para criar "pontos de injeção" para nossa versão Enterprise. **Nenhum destes arquivos altera a lógica interna das telas-padrão do Chatwoot.**

* **Front-end (Vue.js)**
  * `app/javascript/dashboard/routes/dashboard/dashboard.routes.js`: Adicionamos a importação e inicialização do `initializeEnterpriseRoutes()`. **As rotas padrão (como a de Contatos) permanecem inalteradas**.
  * `app/javascript/dashboard/components-next/sidebar/Sidebar.vue`: Adicionamos o hook `injectEnterpriseMenuItems(baseMenu)` para inserir o item **"PDV D+"** no menu lateral, logo após "Conversations" ou "Reports". **O resto do componente opera normalmente conforme o original da versão**.
  * `app/javascript/dashboard/i18n/locale/en/settings.json`: Injeção de traduções customizadas para nossos módulos.

* **Back-end (Ruby/Rails)**
  * `config/routes.rb`: Preservamos o bloco tradicional inteiro do Chatwoot e **apenas adicionamos (no final ou em blocos isolados)** as rotas para endpoints `/enterprise/api/...` e novas views do VueRouter correspondentes ao Kanban, Gestão de Contatos e Boletos.
  * `docker/entrypoints/rails.sh`: Garantimos que o script de boot inicie corretamente nossas dependências em um ambiente de contâiner ajustado.

---

## 2. Injeção de Código Adicional e Modelos (`app/` e `config/`)
Nenhuma classe base do Chatwoot foi sobrescrita. Utilizamos a funcionalidade `ActiveSupport::Concern` do Rails para plugar métodos em classes existentes sem precisar deletar o código nativo.

* `app/models/concerns/extension/account.rb`: Estende a classe original `Account` do Chatwoot para registrar que ela possui várias "Colunas de Kanban" (`has_many :kanban_columns`) e "Cartões de Kanban" (`has_many :kanban_cards`). 
  * > **Aviso:** Não há NENHUMA alteração feita no modelo de `Contact` (Contatos) ou `Conversation` (Conversas) nestas injeções. O funcionamento do Chatwoot Vanilla em relação à lista de contatos está 100% puro.

---

## 3. Diretório Totalmente Isolado (`enterprise/`)
Todos os nossos módulos visuais e lógicas de negócios exclusivas não tocam nas pastas padrões do Chatwoot, ficando isoladas na nossa pasta `enterprise`.

* **Telas Vue (`enterprise/app/javascript/dashboard/routes/dashboard/`)**: `gestao-contatos`, `kanban`, `boletos`.
* **Chamadas de API Customizadas (`enterprise/app/javascript/dashboard/api/`)**: `customContacts.js`, `kanbanCards.js`, `kanbanColumns.js`. Elas não matam o `contacts.js` do Chatwoot, apenas são importadas isoladamente dentro da nossa aba "Gestão de Contatos".
* **Controladores/Rotas Independentes**: Nossas requisições batem apenas nas rotas `enterprise/api/v1/...`.

---

## 4. Banco de Dados e Migrations
Durante o build, copiamos a pasta `db/migrate` que cria apenas tabelas 100% novas para rodar em paralelo às do Chatwoot:

* **Novas Tabelas Criadas**:
  * `kanban_columns`
  * `kanban_cards`
* **Campos Auxiliares Adicionados** (Listados na sequência da *timezone* das migrations):
  * Caching de labels (`cached_labels_list`)
  * Data de deleção lógica do Kanban (`deleted_at` para soft-delete)
  * Campos de arquivamento para Kanban (`archived`, `archived_at`)
  * Data de vencimento e prioridade para Kanban (`priority`, `due_date`)

---

## Conclusão sobre o Bug de F5 na Aba Contatos
Durante a extensa auditoria deste documento e dos *logs* de sua API (que provaram que o Rails devolve os dados em JSON normalmente em `Status 200 OK`), chegamos à conclusão técnica de que **nossos patchs Enterprise não têm qualquer correlação ou intersecção lógica com a falha de renderização do Contatos do Chatwoot após recarregar a página**. 

O Chatwoot na versão **v4.11.0 (branch `develop`)** passou por enormes reestruturações na injeção de dependências do Vue3 (migrando para o padrão `components-next`). É extremamente comum que essa reescrita gere *bugs* nativos neles mesmos onde a tela quebra se for carregada pela URL diretamente (falha no ciclo de vida do Vuex) até que eles lancem o próximo *bugfix* oficial no Github deles. Você pode acompanhar as correções no repositório base ou aguardar semanas até que a branch se estabilize por lá.
