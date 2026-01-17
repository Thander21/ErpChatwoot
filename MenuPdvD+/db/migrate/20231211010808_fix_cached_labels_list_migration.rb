class FixCachedLabelsListMigration < ActiveRecord::Migration[7.0]
  def change
    # This migration fixes the problematic 20231211010807_add_cached_labels_list.rb
    # by removing the line that references ActsAsTaggableOn::Taggable::Cache.included(Conversation)
    # which doesn't exist in the current version

    # The column was already added by the original migration, so we just ensure it's there
    unless column_exists?(:conversations, :cached_label_list)
      add_column :conversations, :cached_label_list, :string
    end

    Conversation.reset_column_information
    # Note: ActsAsTaggableOn::Taggable::Cache.included(Conversation) removed
    # as the constant doesn't exist in current version
  end
end
