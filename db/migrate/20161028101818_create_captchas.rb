class CreateCaptchas < ActiveRecord::Migration
  def change
    create_table :captchas do |t|
      t.string :key, null: false
      t.string :value, null: false

      t.timestamps null: false
    end
    add_index :captchas, :key
  end
end
