class BackfillMemberSlugs < ActiveRecord::Migration[7.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  def up
    # 既存メンバーの slug が nil の場合、プロフィールURL用に採番する
    MigrationUser.where(role: 0, slug: nil).find_each do |member|
      base = member.name.to_s.parameterize.presence || "member"
      candidate = base
      sequence = 1

      while MigrationUser.exists?(slug: candidate)
        sequence += 1
        candidate = "#{base}-#{sequence}"
      end

      member.update_columns(slug: candidate)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "既存データの slug 補完は安全に元に戻せません"
  end
end
