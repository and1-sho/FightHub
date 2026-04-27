class AddPaidAdviceSettingsToAdvices < ActiveRecord::Migration[7.1]
  def change
    add_column :advices, :accepts_paid_advice, :boolean, null: false, default: false
    add_column :advices, :paid_text_menu_enabled, :boolean, null: false, default: false
    add_column :advices, :paid_text_video_menu_enabled, :boolean, null: false, default: false
  end
end
