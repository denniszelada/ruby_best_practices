# Single Principle Responsability
# The class should only have one reason to change.
# Benefits:
#   *Clarity, optimizing for readability first.
#   *Clases are more reusable.
#   *Easier to test it.
#   *Easier to change.
#
# The class should be cohetians, meaning that every peace of the class should be
# strongly related.
# When the class is being hard to test it, it's a good meassure to change it.
# You can do a squint test on the class to verify if it's too much going on
#
# We can define a Responsability as a reason to change, so check which are the 
# reasons to change your methods.
#
# You can't apply all the principles at once, and sometimes you will found that
# tell don't ask will contrarest this principle and you need to find a middle
# ground on how to apply this
#
# To get an overview of the changes on your clases you can use the gem chrun
#   chrun \
#     -c 10 \
#     --start_date '1 year ago' \
#     -iGemfile,Gemfile.lock,config/rotues.rb,db/schema.rb
#
# Example of a class before using SRP

class Invitation < ActiveRecord::Base
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  STATUSES = %w(pending accepted)

  belongs_to :sender, class_name: 'User'
  belongs_to :survey

  before_create :set_token

  validates :recipient_email, presence: true, format: EMAIL_REGEX
  validate :status, inclusion: { in: STATUSES }

  def to_param
    token
  end

  def deliver
    Mailer.invitation_notification(self).deliver
  end

  private

  def set_token
    self.token = SecureRandom.urlsafe_base64
  end
end

# Example After, removing all that doesn't belong to active record and
# adding the tokenized class

class Invitation < ActiveRecord::Base
  STATUSES = %w(pending accepted)

  belongs_to :sender, class_name: 'User'
  belongs_to :survey

  validates :recipient_email, presence: true, email: true
  validates :status, inclusion: { in: STATUSES }
end

# This is represented as a decorator

class TokenizedModel < SimpleDelegator
  def save
    __getobj__.token ||= SecureRandom.urlsafe_base64
    __getobj__.save 
  end

  def to_param
    __getobj__.token
  end
end


# The tests before, has many dependencies, making the test slower

describe Invitation do
  describe '#to_param' do
    it 'returns a token after saving' do
      invitation = create(:invitation)

      expect(invitation.token).to be_present
    end

    it 'returns a unique token for each invitation' do
      invitation = create(:invitation)
      other_invitation = create(:invitation)

      expect(invitation.token).not_to eq(other_invitation.token)
    end
  end
end

# The test for the Tokenized

describe TokenGenerator do
  describe '#generate' do
    it 'returns a token' do
      generator = TokenGenerator.new

      expect(generator.token).to be_present
    end

    it 'returns a unique token' do
      generator = TokenGenerator.new

      expect(generator.token).not_to eq(generator.token)
    end
  end
end

# Example of a class that isn't cohesive because the methods are note related
# this is called incidential cohesion.

module Utils
  def self.generate_token
    SecureRandom.urlsafe_base64
  end

  def self.valid_email?(email)
    email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end
end

# Example of a cohesive class that follow SRP
# in this case all the methods are related to an Email

class Email
  def initialize(string)
    @string = string
  end

  def valid?
    @string =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

  def domain
    @string.split('@').last
  end

  def to_s
    @string
  end
end
