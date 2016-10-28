class AddRefreshAndFailCountToCaptchas < ActiveRecord::Migration
  def change
    add_column :captchas, :refresh_count, :integer, default: 0, null: false
    add_column :captchas, :fail_count, :integer, default: 0, null: false
  end
end
