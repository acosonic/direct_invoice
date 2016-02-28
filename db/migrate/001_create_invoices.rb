class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :company
      t.date :date
    end
  end
end
