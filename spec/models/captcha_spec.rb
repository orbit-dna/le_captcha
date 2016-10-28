require 'rails_helper'

RSpec.describe Captcha, type: :model do
  it "::generate" do
    captcha = Captcha.generate
    expect(captcha).to be_a Captcha
    expect(captcha.persisted?).to be true
    expect(captcha.changed?).to be false
    expect(captcha.key).not_to be_nil
    expect(captcha.value).not_to be_nil

    value = captcha.value
    expect { captcha.reload }.not_to raise_error
    expect(captcha.value).to eq value
  end

  it "can't save without key" do
    captcha = Captcha.new(value: 1)
    expect(captcha.valid?).to be false
    expect(captcha.errors).to have_key(:key)
  end
  it "can't save without value" do
    captcha = Captcha.new(key: 1)
    expect(captcha.valid?).to be false
    expect(captcha.errors).to have_key(:value)
  end
  it "can't save duplicated key" do
    captcha = Captcha.new(key: 1, value: 1)
    expect(captcha.save).to be true
    another_captcha = Captcha.new(key: 1, value: 1)
    expect(another_captcha.valid?).to be false
    expect(another_captcha.errors).to have_key(:key)
  end
  it "saved with value sanitized" do
    value = '  a  B  c  '
    sanitized_value = 'ABC'
    captcha = Captcha.new(key: 1, value: value)
    expect(captcha.save).to be true
    captcha.reload
    expect(captcha.value).to eq sanitized_value
  end

  context "verify" do
    key = 1
    value = ' a B  c  '
    corrects = ['   A bc  ']
    incorrects = ['xcs']

    before :each do
      Captcha.new(key: key, value: value).save!
    end

    corrects.each do |correct|
      it "accept value : #{correct.inspect}" do
        captcha = Captcha.find_by(key: key)
        expect(captcha).to be_a Captcha
        expect(captcha.verify(correct)).to be true
      end
    end

    incorrects.each do |incorrect|
      it "won't accept value : #{incorrect.inspect}" do
        captcha = Captcha.find_by(key: key)
        expect(captcha).to be_a Captcha
        result = nil
        expect { result = captcha.verify(incorrect) }.
          to change { captcha.fail_count }.by(1).
          and change { captcha.try_count }.by(1)
        expect(result).to be false
      end
    end
  end

  it "can refresh" do
    captcha = Captcha.generate
    result = nil
    expect { result = captcha.refresh }.
      to change { captcha.updated_at }.
      and change { captcha.value}.
      and change { captcha.refresh_count }.by(1).
      and change { captcha.try_count }.by(1)
    expect(result).to be true
  end

  it "will expire" do
    time_to_live = Captcha.time_to_live
    captcha = Captcha.generate
    expect(captcha.expired?).to be false

    captcha.update_column(:updated_at, (time_to_live + 1.minute).ago)
    expect(captcha.expired?).to be true
  end

  it "verified to be incorrect if expired" do
    time_to_live = Captcha.time_to_live
    captcha = Captcha.generate
    value = captcha.value

    captcha.update_column(:updated_at, (time_to_live + 1.minute).ago)
    expect(captcha.verify(value)).not_to be true
  end

end
