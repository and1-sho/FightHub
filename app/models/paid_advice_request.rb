class PaidAdviceRequest < ApplicationRecord
  MENU_TEXT_ONLY = Advice::TEXT_ONLY_MENU
  MENU_TEXT_WITH_VIDEO = Advice::TEXT_WITH_VIDEO_MENU

  belongs_to :advice
  belongs_to :request
  belongs_to :member, class_name: "User"
  belongs_to :trainer, class_name: "User"

  validates :menu_code, presence: true
  validates :amount_jpy, numericality: { only_integer: true, greater_than: 0 }
  validates :stripe_checkout_session_id, uniqueness: true, allow_blank: true

  def menu_label
    advice.paid_menu_label(menu_code)
  end
end
