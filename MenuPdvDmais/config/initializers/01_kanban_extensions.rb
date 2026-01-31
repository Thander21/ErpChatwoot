# Carrega extensões do modelo para o Kanban
Rails.application.config.to_prepare do
  begin
    # Attempts to load from the merged path (/app/app/models...)
    # This path assumes the 'app/models/concerns/extension/account.rb' from MenuPdvDmais 
    # was correctly copied to /app/app/models/concerns/extension/account.rb
    extension_path = Rails.root.join('app', 'models', 'concerns', 'extension', 'account.rb')
    
    if File.exist?(extension_path)
      require extension_path
      Rails.logger.info "Kanban Extension loaded from: #{extension_path}"
    else
      Rails.logger.error "Kanban Extension NOT FOUND at: #{extension_path}"
    end
  rescue LoadError => e
    Rails.logger.error "Failed to load Kanban Account Extension: #{e.message}"
  end
end
