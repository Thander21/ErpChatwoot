# Usage: bundle exec rails runner seed_kanban_tarefas.rb

def log(msg)
  puts "[SeedKanban] #{msg}"
end

def error(msg)
  puts "[SeedKanban] ERROR: #{msg}"
end

log "Starting seeding..."

begin
  account = Account.first
  unless account
    log "No account found! Aborting."
    exit 1
  end

  log "Using Account: #{account.name} (ID: #{account.id})"

  inbox = account.inboxes.first
  unless inbox
    log "No inbox found! Creating a placeholder inbox..."
    inbox = Inbox.create!(account: account, name: "Test Inbox", channel: Channel::WebWidget.create!(account: account, website_url: "https://test.com"))
  end
  log "Using Inbox: #{inbox.name} (ID: #{inbox.id})"

  user = account.users.first
  unless user
    log "No user found! Using account owner if available..."
    user = account.users.first
  end
  log "Using User: #{user&.name || 'None'} (ID: #{user&.id})"

  contact = account.contacts.first
  unless contact
    contact = Contact.create!(account: account, name: "Cliente Teste", email: "cliente@teste.com")
  end
  log "Using Contact: #{contact.name} (ID: #{contact.id})"

  # Ensure ContactInbox exists
  contact_inbox = ContactInbox.find_by(contact: contact, inbox: inbox)
  unless contact_inbox
    contact_inbox = ContactInbox.create!(contact: contact, inbox: inbox, source_id: SecureRandom.uuid)
    log "Created ContactInbox (ID: #{contact_inbox.id})"
  else
    log "Using existing ContactInbox (ID: #{contact_inbox.id})"
  end

  # Helper to create conversation
  def create_conv(account, inbox, contact, contact_inbox, status, assignee = nil, snoozed_until = nil, label = "")
    if assignee
       log "Creating conversation for assignee: #{assignee.id}"
    end

    conv = Conversation.new(
      account: account,
      inbox: inbox,
      contact: contact,
      contact_inbox: contact_inbox,
      status: status,
      assignee: assignee,
      snoozed_until: snoozed_until
    )
    
    if conv.save
       Message.create!(
        account: account,
        inbox: inbox,
        conversation: conv,
        message_type: 0, 
        content: "Mensagem de teste para status: #{label}"
      )
      log "Created Conversation ##{conv.display_id} - #{label}"
    else
      error "Failed to create conversation '#{label}': #{conv.errors.full_messages.join(', ')}"
    end
  rescue => e
    error "Exception creating conversation '#{label}': #{e.message}"
    puts e.backtrace.first(5)
  end

  # 1. Pending (Status 0)
  create_conv(account, inbox, contact, contact_inbox, 0, nil, nil, "Pendente")

  # 2. Open Unassigned (Status 1)
  create_conv(account, inbox, contact, contact_inbox, 1, nil, nil, "Aberta Não Atribuída")

  # 3. Open Assigned (Status 1)
  if user
    create_conv(account, inbox, contact, contact_inbox, 1, user, nil, "Aberta Atribuída")
  else
    log "Skipping Assigned test (no user)"
  end

  # 4. Snoozed (Status 1 + snoozed_until)
  create_conv(account, inbox, contact, contact_inbox, 1, nil, 2.days.from_now, "Adiada (Snoozed)")

  # 5. Resolved (Status 2)
  create_conv(account, inbox, contact, contact_inbox, 2, nil, nil, "Resolvida")

  log "Seeding complete!"

rescue => main_error
  error "Critical failure: #{main_error.message}"
  puts main_error.backtrace
end
