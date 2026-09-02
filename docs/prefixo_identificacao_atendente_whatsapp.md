# 📋 Especificação Técnica: Prefixo Automático do Nome do Atendente no WhatsApp

## 🎯 Objetivo
Permitir que todas as mensagens enviadas por **atendentes humanos** através de canais do WhatsApp (Meta Cloud API / 360dialog) incluam automaticamente o nome do atendente no **início** do texto da mensagem, no formato de destaque (negrito):

```text
*NomeDoAgente*:
Mensagem digitada no chat pelo atendente
```

---

## 🛡️ Diretriz de Arquitetura (Desacoplamento do Core)

Para garantir que o repositório `chatwoot-base/` permaneça 100% puro e atualizável via `./update_upstream.sh`, a implementação será feita exclusivamente através da camada de extensão:

1. **Local do Código**: Módulo desacoplado em `MenuPdvDmais/enterprise/` ou via decorator Rails / patch isolado.
2. **Injeção no Docker**: Gerenciado durante a etapa de cópia de overlays do `Dockerfile`.
3. **Sem Conflitos no Upstream**: Atualizações futuras do Chatwoot não tocarão nem sobrescreverão essa regra de negócio.

---

## ⚙️ Regras de Negócio e Comportamento

1. **Condição para Inserção do Prefixo**:
   * O remetente da mensagem (`message.sender`) deve ser um usuário humano (`User` / Atendente).
   * O tipo da mensagem deve ser enviada/saída (`outgoing`).
   * O canal de destino deve ser WhatsApp (`Channel::Whatsapp`).

2. **Exceções (Sem Injeção de Prefixo)**:
   * **Mensagens Automáticas / Bots**: `AgentBot` ou mensagens geradas por automações/fluxos.
   * **Disparos do ERP PDV D+ / API Externa**: Mensagens enviadas sem vínculo direto de um operador na interface web do Chatwoot (ou caso já possuam prefixo próprio).
   * **Mensagens Privadas / Notas Internas**: Notas privadas continuam visíveis apenas para a equipe interna sem alteração.

3. **Suporte a Mídias e Anexos**:
   * Em envios com legendas (*captions*) de imagens, vídeos e documentos, o prefixo do atendente será injetado no início da legenda da mesma forma.

---

## 🛠️ Especificação da Implementação Técnica

### A. Interceptador de Envio WhatsApp (Backend)
* **Classe Alvo**: `Whatsapp::Providers::WhatsappCloudService` (ou `Whatsapp::SendOnWhatsappService`).
* **Lógica**:
  ```ruby
  module Enterprise
    module WhatsappAgentPrefix
      def send_text_message(phone_number, message)
        format_agent_prefix(message)
        super(phone_number, message)
      end

      def build_attachment_content(type, attachment, message)
        format_agent_prefix(message)
        super(type, attachment, message)
      end

      private

      def format_agent_prefix(message)
        return unless message.outgoing? && message.sender.is_a?(User)
        return if message.content.blank?

        prefix = "*#{message.sender.name}*:\n"
        unless message.content.start_with?(prefix)
          message.content = "#{prefix}#{message.content}"
        end
      end
    end
  end
  ```

### B. Registro no Mapeamento
* Atualizar `.ai/file-registry.md` e o `Dockerfile` para incluir o arquivo no processo de build quando formos implementar.

---

## 🗺️ Roadmap de Execução

1. 🔄 **Passo 1: Atualização do Chatwoot Base**
   * Executar `./update_upstream.sh` para a versão mais recente do Chatwoot.
   * Verificar se houve mudanças no core (`git diff`) e ajustar os patches existentes em `MenuPdvDmais/core-patches/`.

2. 🧪 **Passo 2: Compilação e Testes da Versão Atualizada**
   * Fazer o build do Docker (`docker compose build`).
   * Validar o funcionamento de todas as telas (Kanban, Gestão de Contatos, Chat padrão).

3. 🚀 **Passo 3: Implementação do Prefixo do Atendente**
   * Criar os arquivos de extensão em `MenuPdvDmais/`.
   * Testar o envio no WhatsApp e validar a renderização final no celular do cliente.
