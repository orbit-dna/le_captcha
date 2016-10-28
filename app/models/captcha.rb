class Captcha < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  # TODO
  # regularly clear old datas

  attr_reader :verified
  def verified?
    @verified
  end

  after_initialize { self.refresh_count, self.fail_count = 0,0 }
  before_validation :upcase_value

  def expired?
    self.class.time_to_live.ago > updated_at
  end

  def try_count
    fail_count.to_i + refresh_count.to_i
  end

  def verify(answer)
    answer = sanitize(answer)
    @verified = expired? ? nil : (value == answer)
    @verified ? destroy : increment!(:fail_count)
    @verified
  end

  def refresh
    increment(:refresh_count)
    self.value = self.class.generate_value
    save
  end

  private

    def sanitize(val)
      val.strip.upcase.tr(" ","") if val
    end

    def upcase_value
      self.value = sanitize(value)
    end

  # CLASS METHODS

  public

  def self.generate(options={})
    key = generate_key(options)
    value = generate_value
    create(key: key, value: value)
  end

  def self.generate_key(options={})
    args = options.to_a << (Time.now.to_f * 1_000_000_000).to_s << SecureRandom.hex
    Digest::SHA1.hexdigest(args.join)
  end

  def self.generate_value
    value = 6.times.map { |x| (65+rand(26)).chr }.join
  end

  def self.time_to_live
    3.minutes
  end
  def self.time_to_survive
    2.hours
  end
end
