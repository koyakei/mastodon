## タグ付与時に付与した量と対象ポストを記録する
## 複数回おなじポストに対して付与した場合は複数回このテーブルにレコードが追加される
class CreateKTagTradingHistory < ActiveRecord::Migration[7.1]
  def change
    create_table :k_tag_trading_history do |t|
      t.references :k_tag, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.integer :trade_count, null: false, default: 1

      t.timestamps
    end
  end
end
