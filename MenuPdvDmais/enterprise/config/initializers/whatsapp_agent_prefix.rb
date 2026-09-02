# frozen_string_literal: true

module Enterprise
  module WhatsappAgentPrefixPresenter
    def outgoing_content
      rendered = super

      if should_apply_whatsapp_agent_prefix?(rendered)
        prefix = "*#{sender.name}*:\n"
        rendered = "#{prefix}#{rendered}" unless rendered.start_with?(prefix)
      end

      rendered
    end

    private

    def should_apply_whatsapp_agent_prefix?(rendered)
      return false if rendered.blank?
      return false unless outgoing? && sender.is_a?(User)
      return false if conversation&.inbox.blank?

      channel_type = conversation.inbox.channel_type
      return true if channel_type == 'Channel::Whatsapp'

      if channel_type == 'Channel::TwilioSms'
        channel = conversation.inbox.channel
        return channel.respond_to?(:medium) && channel.medium == 'whatsapp'
      end

      false
    end
  end
end

Rails.configuration.to_prepare do
  unless MessageContentPresenter.ancestors.include?(Enterprise::WhatsappAgentPrefixPresenter)
    MessageContentPresenter.prepend(Enterprise::WhatsappAgentPrefixPresenter)
  end
end
