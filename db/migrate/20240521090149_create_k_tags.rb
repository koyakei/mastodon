class CreateKTags < ActiveRecord::Migration[7.1]
  def change
    create_table :k_tags do |t|
      t.text :name
      t.text :description
      t.references :account, null: false, foreign_key: true
      t.integer :followers_count, default: 0

      t.timestamps
    end
  end
end
