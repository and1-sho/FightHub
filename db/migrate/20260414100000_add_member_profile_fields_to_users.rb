class AddMemberProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    # メンバープロフィール用
    add_column :users, :birth_date, :date
    add_column :users, :stance, :string
    add_column :users, :weight_class, :string
  end
end
