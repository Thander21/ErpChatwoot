# Relatório de QA e Usabilidade (Quality Assurance)

**Status:** 🟢 Aprovado com Ressalvas
**Data da Última Atualização:** 06/Fevereiro/2026

## 1. Usabilidade (UX)

- ✅ **Notificações**: A substituição de `alert()` (bloqueante) por **Toasts** (`BUS_EVENTS`) melhorou drasticamente a fluidez.
- ✅ **Feedback Visual**: Botões agora mostram estado de "Loading" real, evitando cliques duplos.

## 2. Consistência

- **Visual**: O módulo de Gestão de Contatos agora é visualmente indistinguível das telas nativas do Chatwoot.

## 3. Backlog de Bugs & Melhorias

- [ ] **UX / Performance**: Ao clicar em "Atualizar Empresas", o usuário não tem feedback de progresso (barra de progresso) se a lista for grande. (Depende da correção do Backend).
- [ ] **Mobile**: O Kanban exibe muitas informações por card. Em telas pequenas, considerar ocultar campos menos relevantes (ex: ID, datas secundárias).
- [ ] **Mobile**: O menu lateral (Sidebar) customizado precisa de validação extra em telas muito estreitas (iPhone SE).
