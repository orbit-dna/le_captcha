class Captcha < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true
end
