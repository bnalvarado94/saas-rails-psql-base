class AddEmailConfirmationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :confirmation_token_digest, :string
    add_column :users, :confirmation_sent_at, :datetime
  end
end
