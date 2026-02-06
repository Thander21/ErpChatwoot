# Relatório de Arquitetura e Engenharia (Tech Lead)

**Status:** 🟡 Estável com Riscos de Manutenção
**Data da Última Atualização:** 06/Fevereiro/2026

## 1. Arquitetura de Overlay

O projeto opera como um "Patch" sobre o `chatwoot-base`.

### 🚨 Riscos Identificados

- **Vendor Lock-in de Arquivos**: Arquivos como `Sidebar.vue` (e outros core) foram copiados e modificados.
  - _Problema_: Atualizações do Chatwoot upstream que alterem a sidebar quebrarão silenciosamente nossa versão.
  - _Mitigação_: Implementar script de diff/check no CI para alertar discrepâncias com o upstream.

## 2. Padrões de Código

- **Container/Presenter**: Adotado com sucesso no módulo Kanban. Deve ser o padrão para todas as novas interfaces complexas.
- **Service Layer**: Acesso direto via `axios` em componentes Vue foi banido. Todo acesso a API deve passar por classes em `dashboard/api/`.

## 3. Backlog Técnico (Arquitetura)

- [ ] **State Management**: Migrar de Composables gigantes (`useKanban`) para **Pinia** (padrão Vue 3 + Chatwoot moderno).
- [ ] **Modais**: Integrar com o sistema global de modais (`useModal`) para evitar duplicação de lógica de overlay.
- [ ] **Observabilidade**: Adicionar logs estruturados para ações críticas do Kanban (movimentação de cards, deleção).
