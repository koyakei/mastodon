class CreateKTagRelations < ActiveRecord::Migration[7.1]
  def change
    create_table :k_tag_relations do |t|
      t.references :account, null: false, foreign_key: true
      t.references :k_tag, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.boolean :is_fixed, null: false, default: false

      t.timestamps
    end
    add_index :k_tag_relations, [:k_tag_id, :status_id], unique: true
  end
end
