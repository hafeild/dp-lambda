class User < ApplicationRecord
  ## Much of this is lifted from Code Annotator 
  ## (https://github.com/hafeild/code-annotator/blob/master/app/models/user.rb)
  ## User's have...
  ## - username
  ## - email
  ## - first_name
  ## - last_name
  ## - role (faculty, student, etc.)
  ## - field_of_study
  ## - password_digest
  ## - activation_digest
  ## - activated
  ## - activated_at
  ## - remember_digest
  ## - reset_digest
  ## - reset_sent_at
  ## - created_on
  ## - updated_on
  ## - permission_level
  ## - permission_granted_on
  ## - permission_granted_by

  attr_accessor :remember_token, :activation_token, :reset_token
  
  has_secure_password

  ## Emails will be lowercased.
  before_save :downcase_email

  ## Creates a unique activation code, which will be emailed to users.
  before_create :create_activation_digest

  ## Validate username -- must be there, must be unique, and can't be longer 
  ## 50 characters.
  validates :username, presence: true, length: {maximum: 50},
    uniqueness: {case_sensitive: false}

  ## Validate first and last names -- must be there and can't be longer than 
  ## 50 chars.
  validates :first_name, presence: true, length: {maximum: 50}
  validates :last_name, presence: true, length: {maximum: 50}

  ## Validate email -- can't be longer than 255 characters
  ## and must be in the correct format.
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
      format: {with: VALID_EMAIL_REGEX}

  ## Validate a new password.
  validates :password, presence: true,
    length: {minimum: 8, maximum: 50}, allow_nil: true

  ## Validate role.
  validates :role, presence: true

  ## Validate field of study.
  validates :field_of_study, presence: true

  ## Uses BCrypt to salt/encrypt a password.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  ## Creates a new random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  ## Adds a remember token to the database.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  ## Checks if the digest of the given token matches the stored attribute 
  ## digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user (removes the remember token).
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_email_verification_email
    update_attribute(:activated, false)
    update_attribute(:activation_token, User.new_token)
    update_attribute(:activation_digest, User.digest(activation_token))
    save
    UserMailer.email_verification(self).deliver_now
  end


  # Sets the password reset attributes.
  def create_reset_digest
    update_attribute(:reset_token, User.new_token)
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
    save
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end  

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def full_name
    "#{first_name} #{last_name}" 
  end
  
  def can_edit?
    permission_level == :editor or permission_level == :admin
  end
  
  def is_admin?
    permission_level == :admin
  end

  private
    ## Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    ## Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
    
end