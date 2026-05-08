class AddConfirmedAtAndNamesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name, :string unless column_exists?(:users, :first_name)
    add_column :users, :last_name, :string unless column_exists?(:users, :last_name)
    add_column :users, :confirmed_at, :datetime unless column_exists?(:users, :confirmed_at)
  end
end
