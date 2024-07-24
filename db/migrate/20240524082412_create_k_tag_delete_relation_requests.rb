class CreateKTagDeleteRelationRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :k_tag_delete_relation_requests do |t|
      t.references :k_tag_relation, null: true, foreign_key: true
      t.references :requester, null: false, foreign_key: {to_table: :accounts}
      t.text :request_comment, null: false, default: ''
      t.text :review_comment, null: false, default: ''
      t.integer :decision_status, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :k_tag_delete_relation_requests, [:requester_id, :k_tag_relation_id], unique: true
  end
end
