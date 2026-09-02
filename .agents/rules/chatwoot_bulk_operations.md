# Regras e Guia Operacional: Chatwoot Bulk Operations & Data Cleanup

## 1. Campanhas de WhatsApp no Chatwoot
- Em campanhas de modelo WhatsApp (HSM), instrua o uso de tags Liquid como `{{ contact.name }}` ou `{{ contact.first_name }}` nos parâmetros de variáveis para personalizar dinamicamente o nome de cada contato.
- A segmentação de público exige a criação e atribuição de etiquetas (Labels).

## 2. Operações em Lote via Rails Console (Container `rails`)
- Ao lidar com etiquetagem ou modificação de milhares de contatos, prefira o console Rails no container `rails`:
  `Contact.find_each { |c| c.add_labels(['nome_etiqueta']) }`

## 3. Limpeza de Contatos Inválidos e LIDs
- Contatos órfãos (sem conversa) com números no formato LID (`1076...`, `+10...` ou tamanho > 15) devem ser identificados via `left_joins(:conversations)`.
- **Regra de Terminal Web (ex: Coolify):** Nunca imprima listas longas que excedam o buffer do terminal web. Forneça scripts de checagem booleana/resumida antes de executar exclusões (`destroy_all`).
