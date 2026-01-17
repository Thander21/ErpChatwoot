class AddCachedLabelsList < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :cached_label_list, :string
    Conversation.reset_column_information
    # Note: ActsAsTaggableOn::Taggable::Cache.included(Conversation) removed
    # as the constant doesn't exist in current version
  end
end
