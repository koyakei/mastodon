class CreateFollowKTags < ActiveRecord::Migration[7.1]
  def change
    create_table :follow_k_tags do |t|
      t.references :k_tag, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
    add_index :single_follow, [:account_id, :k_tag_id], unique: true
  end
end
