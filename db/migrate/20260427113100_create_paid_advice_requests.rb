class CreatePaidAdviceRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :paid_advice_requests do |t|
      t.references :advice, null: false, foreign_key: true
      t.references :request, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: { to_table: :users }
      t.references :trainer, null: false, foreign_key: { to_table: :users }
      t.string :menu_code, null: false
      t.integer :amount_jpy, null: false
      t.string :status, null: false, default: "checkout_started"
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.datetime :paid_at

      t.timestamps
    end

    add_index :paid_advice_requests, :stripe_checkout_session_id, unique: true
  end
end
