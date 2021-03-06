class CreateInvoiceParts < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_parts do |t|
      t.references :invoice, foreign_key: true
      t.references :usage, foreign_key: true
      t.string :type
      t.decimal :amount
      t.string :label
      t.string :label_2
      t.integer :position

      t.timestamps
    end
  end
end
