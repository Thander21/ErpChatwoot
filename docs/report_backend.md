# Relatório de Backend (Ruby on Rails)

**Status:** 🔴 Risco de Performance Crítico
**Data da Última Atualização:** 06/Fevereiro/2026

## 1. Análise de Controladores

### `KanbanCardsController`

- ✅ **N+1 Queries**: Resolvido com uso de `.includes(:conversation, :contact, ...)` no método `index`.
- ✅ **Integridade**: Método `move` utiliza Transações SQL corretamente.

### 🚨 Risco Crítico: `sync_companies`

O método `sync_companies` atual itera sobre **todos os contatos** da conta de forma síncrona:

```ruby
@account.contacts.where(...).find_each do |contact|
  # ... Lógica pesada de busca/criação
end
```

**Impacto**: Contas com > 5.000 contatos sofrerão timeout (HTTP 504) e o servidor travará durante a execução.

## 2. Backlog Técnico (Backend)

- [ ] **Prioridade Alta**: Converter `sync_companies` e `cleanup_companies` para **Sidekiq Jobs** (Processamento em Background).
- [ ] **Segurança**: Auditar Policies (Pundit). Verificar se agentes comuns podem deletar cards/colunas.
- [ ] **Testes**: Adicionar RSpec para garantir que a movimentação de cards respeita a ordem corretamente.
