class PaidAdviceRequest < ApplicationRecord
  MENU_TEXT_ONLY = Advice::TEXT_ONLY_MENU
  MENU_TEXT_WITH_VIDEO = Advice::TEXT_WITH_VIDEO_MENU
  STATUS_CHECKOUT_STARTED = "checkout_started".freeze
  STATUS_PAID_LEGACY = "paid".freeze
  STATUS_IN_PROGRESS = "in_progress".freeze
  STATUS_DELIVERED = "delivered".freeze
  STATUS_COMPLETED = "completed".freeze
  AUTO_COMPLETE_AFTER = 3.days

  belongs_to :advice
  belongs_to :request
  belongs_to :member, class_name: "User"
  belongs_to :trainer, class_name: "User"
  has_one_attached :delivery_video

  validates :menu_code, presence: true
  validates :amount_jpy, numericality: { only_integer: true, greater_than: 0 }
  validates :stripe_checkout_session_id, uniqueness: true, allow_blank: true
  validates :status, presence: true
  validates :status, inclusion: {
    in: [STATUS_CHECKOUT_STARTED, STATUS_PAID_LEGACY, STATUS_IN_PROGRESS, STATUS_DELIVERED, STATUS_COMPLETED]
  }
  validates :delivery_body, length: { maximum: 3000 }, allow_blank: true

  scope :active_for_member, ->(member_id) { where(member_id: member_id).where.not(status: STATUS_CHECKOUT_STARTED) }
  scope :active_for_trainer, ->(trainer_id) { where(trainer_id: trainer_id).where.not(status: STATUS_CHECKOUT_STARTED) }

  def self.finalize_overdue_delivered!
    overdue_scope = where(status: STATUS_DELIVERED).where("delivered_at <= ?", AUTO_COMPLETE_AFTER.ago)
    overdue_scope.update_all(status: STATUS_COMPLETED, completed_at: Time.current, updated_at: Time.current)
  end

  def menu_label
    advice.paid_menu_label(menu_code)
  end

  def menu_label_for_transaction
    case menu_code
    when MENU_TEXT_WITH_VIDEO then "【テキスト＋動画】の追加アドバイスが購入されました。"
    when MENU_TEXT_ONLY then "テキストのみ"
    else menu_label
    end
  end

  def purchase_notice_message
    case menu_code
    when MENU_TEXT_WITH_VIDEO
      menu_label_for_transaction
    else
      "#{menu_label_for_transaction}が購入されました。"
    end
  end

  def approval_notice_message(viewer:)
    if viewer.id == member_id
      case menu_code
      when MENU_TEXT_WITH_VIDEO then "【テキスト＋動画】の追加アドバイスを承認しました。"
      when MENU_TEXT_ONLY then "【テキストのみ】の追加アドバイスを承認しました。"
      else "追加アドバイスを承認しました。"
      end
    else
      case menu_code
      when MENU_TEXT_WITH_VIDEO then "【テキスト＋動画】の追加アドバイスが承認されました。"
      when MENU_TEXT_ONLY then "【テキストのみ】の追加アドバイスが承認されました。"
      else "追加アドバイスが承認されました。"
      end
    end
  end

  # 決済確定時刻（未設定のレコード向けに作成日時で代用）
  def payment_confirmed_at
    paid_at.presence || created_at
  end

  def in_progress?
    status == STATUS_IN_PROGRESS || status == STATUS_PAID_LEGACY
  end

  # トレーナーが納品フォームを出していい状態（決済済みで未納品・未完了）
  def awaiting_trainer_delivery?
    return false if delivered? || completed?
    return true if in_progress?
    # 決済完了後にステータス更新が遅れた・取りこぼした場合の救済
    paid_at.present? && status == STATUS_CHECKOUT_STARTED
  end

  def delivered?
    status == STATUS_DELIVERED
  end

  def completed?
    status == STATUS_COMPLETED
  end

  def requires_video_delivery?
    menu_code == MENU_TEXT_WITH_VIDEO
  end

  # 取引詳細のトレーナー向け納品フォーム用
  def delivery_form_hint_for_trainer
    if requires_video_delivery?
      "【テキスト＋動画】の購入です。テキストと動画の両方が必須です。"
    else
      "【テキストのみ】の購入です。詳しいアドバイスのテキストを入力してください（動画は不要です）。"
    end
  end

  def status_label
    case status
    when STATUS_CHECKOUT_STARTED, STATUS_PAID_LEGACY, STATUS_IN_PROGRESS then "対応中"
    when STATUS_DELIVERED then "納品済み"
    when STATUS_COMPLETED then "完了"
    else "対応中"
    end
  end
end
