# Refactoring & Execution - ErpChatwoot

## 🛠️ Workflow de Modificação (A Regra de Ouro)
1. **Identificar**: Encontre o arquivo no `chatwoot-base/`.
2. **Avaliar**:
   - Se for uma funcionalidade nova: Crie em `MenuPdvDmais/enterprise/`.
   - Se for alteração no core: Copie de `chatwoot-base/` para `MenuPdvDmais/core-patches/` mantendo a estrutura original.
3. **Registrar**: Atualize `.ai/file-registry.md` com a nova entrada.
4. **Implementar**: Aplique as mudanças no arquivo dentro de `MenuPdvDmais/`.
5. **Validar**: Verifique se o `Dockerfile` está configurado para aplicar o patch ou incluir a nova pasta.

## 🔄 Refatoração Incremental
- **Escopo**: Mantenha as refatorações pequenas e focadas. Evite "Big Bang refactoring".
- **Rollback**: Teste as alterações localmente com Docker antes de commitar para garantir um rollback fácil se necessário.
- **Compatibilidade**: Garanta que as mudanças não quebrem a compatibilidade com futuras atualizações do Chatwoot original (upstream).

## 📊 Validação de Mudanças
- **Logs de Build**: Acompanhe o build do Docker para garantir que o overlay foi aplicado com sucesso.
- **Runtime Check**: Utilize o console do Rails ou testes manuais via browser para confirmar o comportamento.
