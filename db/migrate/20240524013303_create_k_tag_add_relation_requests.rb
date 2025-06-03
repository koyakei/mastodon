class CreateKTagAddRelationRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :k_tag_add_relation_requests do |t|
      t.references :k_tag, null: false, foreign_key: true
      t.references :requester, null: false, foreign_key: {to_table: :accounts}
      t.references :target_account, null: false, foreign_key: {to_table: :accounts}
      t.references :status, null: false, foreign_key: true
      t.integer :request_status, null: false, default: 0
      t.text :request_comment, null: false, default: ''
      t.text :review_comment, null: false, default: ''
      t.timestamps
    end
    add_index :k_tag_add_relation_requests, [:requester_id, :k_tag_id, :status_id], unique: true
  end

end
