class MembersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_member
  before_action :authorize_member_owner!, only: [:edit, :update]

  # プロフィール閲覧（公開）
  def show
  end

  def edit
  end

  def update
    handle_image_removal_on_update!

    if @member.update(member_profile_params)
      redirect_to member_path(@member), notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_member
    @member = User.member.find_by(slug: params[:slug])
    return if @member.present?

    @member = User.member.find_by!(id: params[:slug]) if params[:slug].to_s.match?(/\A\d+\z/)
  end

  def authorize_member_owner!
    return if current_user == @member

    redirect_to member_path(@member), alert: "このプロフィールを編集する権限がありません"
  end

  def member_profile_params
    params.require(:user).permit(
      :profile_affiliation,
      :profile_prefecture,
      :profile_area_detail,
      :boxing_started_on,
      :birth_date,
      :stance,
      :weight_class,
      :profile_bio,
      :avatar_image,
      :header_image
    )
  end

  def handle_image_removal_on_update!
    if params.dig(:user, :remove_avatar_image) == "1" && params.dig(:user, :avatar_image).blank?
      @member.avatar_image.purge if @member.avatar_image.attached?
    end

    if params.dig(:user, :remove_header_image) == "1" && params.dig(:user, :header_image).blank?
      @member.header_image.purge if @member.header_image.attached?
    end
  end
end
