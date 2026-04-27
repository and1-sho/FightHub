class Advice < ApplicationRecord
  include ValidatesAttachedVideo

  TEXT_ONLY_MENU = "text_only".freeze
  TEXT_WITH_VIDEO_MENU = "text_with_video".freeze
  TEXT_ONLY_PRICE_JPY = 1000
  TEXT_WITH_VIDEO_PRICE_JPY = 2000

  # adviceのボディーを必須項目にする
  validates :body, presence: true

  # トレーナーからの動画は1アドバイスにつき1本（MP4 / MOV・100MBまで・詳細で再生）
  has_one_attached :video
  has_one_attached :video_thumbnail

  # adviceはrequestに属する
  belongs_to :request

  # adviceはトレーナー（User）に属する
  belongs_to :user

  has_many :paid_advice_requests, dependent: :destroy

  validates :user_id, uniqueness: { scope: :request_id }
  validate :paid_menu_selection_required_when_enabled
  before_validation :normalize_paid_advice_settings

  def paid_menu_options
    options = []
    options << { code: TEXT_ONLY_MENU, label: "詳しいテキストのみ", price_jpy: TEXT_ONLY_PRICE_JPY } if paid_text_menu_enabled_value?
    options << { code: TEXT_WITH_VIDEO_MENU, label: "詳しいテキスト＋動画解説", price_jpy: TEXT_WITH_VIDEO_PRICE_JPY } if paid_text_video_menu_enabled_value?
    options
  end

  def accepts_paid_advice_enabled?
    accepts_paid_advice_value?
  end

  def paid_menu_available?(menu_code)
    paid_menu_options.any? { |option| option[:code] == menu_code.to_s }
  end

  def paid_menu_price_jpy(menu_code)
    option = paid_menu_options.find { |candidate| candidate[:code] == menu_code.to_s }
    option&.fetch(:price_jpy)
  end

  def paid_menu_label(menu_code)
    option = paid_menu_options.find { |candidate| candidate[:code] == menu_code.to_s }
    option&.fetch(:label)
  end

  private

  def normalize_paid_advice_settings
    return if accepts_paid_advice_value?

    self[:paid_text_menu_enabled] = false if has_attribute?(:paid_text_menu_enabled)
    self[:paid_text_video_menu_enabled] = false if has_attribute?(:paid_text_video_menu_enabled)
  end

  def paid_menu_selection_required_when_enabled
    return unless accepts_paid_advice_value?
    return if paid_text_menu_enabled_value? || paid_text_video_menu_enabled_value?

    errors.add(:base, "有料アドバイスを受け付ける場合は、受け付ける内容を1つ以上選択してください")
  end

  def accepts_paid_advice_value?
    has_attribute?(:accepts_paid_advice) && !!self[:accepts_paid_advice]
  end

  def paid_text_menu_enabled_value?
    has_attribute?(:paid_text_menu_enabled) && !!self[:paid_text_menu_enabled]
  end

  def paid_text_video_menu_enabled_value?
    has_attribute?(:paid_text_video_menu_enabled) && !!self[:paid_text_video_menu_enabled]
  end
end
