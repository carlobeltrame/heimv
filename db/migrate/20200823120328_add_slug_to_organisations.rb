class AddSlugToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :slug, :string
    add_index :organisations, :slug, unique: true
    remove_column :organisations, :domain, :string
  end
end
