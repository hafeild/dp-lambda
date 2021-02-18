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
  ## - permission_level_granted_on
  ## - permission_level_granted_by
  ## - deleted
  ## - is_registered
  ## - created_by (user)
  ## - authored_assignment_groups (AssignmentGroups)
  ## - instructed_assignments (Assignments)
  ## - created_assignment_groups (AssignmentGroups)
  ## - created_assignments (Assignments)

  attr_accessor :remember_token, :activation_token, :reset_token

  has_and_belongs_to_many :authored_assignment_groups, 
    class_name: "AssignmentGroup", join_table: "assignment_groups_authors"
  has_and_belongs_to_many :instructed_assignments, 
    class_name: "Assignment", join_table: "assignments_instructors"
  has_many :created_assignment_groups, 
    class_name: "AssignmentGroup", foreign_key: "creator_id"
  has_many :created_assignments, 
    class_name: "Assignment", foreign_key: "creator_id"

  has_secure_password
  # has_secure_password validations: false

  has_many :permission_requests
  # has_many :reviewed_permission_requests, through: :permission_requests,
  #   source: :reviewed_by 
  belongs_to :permission_level_granted_by, class_name: "User", optional: true
  belongs_to :created_by, class_name: "User", optional: true

  ## Emails will be lowercased.
  before_save :downcase_email

  ## Creates a unique activation code, which will be emailed to users.
  before_create :create_activation_digest



  #########################################
  ## Validations for stubs and non-stubs:
  ##
  ## Validate first and last names -- must be there and can't be longer than 
  ## 50 chars.
  validates :first_name, presence: true, length: {maximum: 50}
  validates :last_name, presence: true, length: {maximum: 50}

  ## Validate email -- can't be longer than 255 characters
  ## and must be in the correct format.
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  NO_AT_SIGNS_REGEX = /\A[^@]*\z/i
  validates :email, presence: true, length: {maximum: 255},
      format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}

  ## Validate username -- must be there, must be unique, and can't be longer 
  ## 50 characters.
  validates :username, presence: true, length: {maximum: 50},
  uniqueness: {case_sensitive: false}, format: {with: NO_AT_SIGNS_REGEX}

  validates :is_registered, inclusion: { in: [true, false] }

  ## Validate a new password.
  validates :password, presence: true,
    length: {minimum: 8, maximum: 50}, allow_nil: true
  ##
  ########################################

  ##############################
  ## Validations for non-stubs:
  ##
  ## A stub is a user placeholder created by another user, e.g., so they can
  ## label that "user" as an author or instrtuctor. User stubs
  ## are unregistered users. A new user may signup and take over a stub if
  ## their email matches.
  def is_stub?
    is_registered == false
  end

  with_options unless: :is_stub? do |non_stub|

    ## Validate role.
    non_stub.validates :role, presence: true

    ## Validate field of study.
    non_stub.validates :field_of_study, presence: true

    # ## Validate a new password.
    # non_stub.validates :password, presence: true,
    #   length: {minimum: 8, maximum: 50}, allow_nil: true
    
  end
  ##
  ##############################

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
  
  # Sends permissions changed email.
  def send_permissions_changed_email
    UserMailer.permissions_changed(self).deliver_now
  end
  
  # Sends email verification email (to make sure their email address is 
  # correct).
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
    permission_level == "editor" or permission_level == "admin"
  end
  
  def is_admin?
    permission_level == "admin"
  end

  ## Gets a list of admins.
  def User.admins
    User.where({permission_level: "admin"}) || []
  end
  
  def is_deleted?
    deleted != false
  end

  def summary_data_json
    {
      id: id,
      first_name: first_name,
      last_name: last_name,
      #email: email
      username: username
    }
  end

  searchable do
    text :username, {as: :username_autocompletable}
    text :email, {as: :email_autocompletable}
    text :last_name, {as: :last_name_autocompletable}
    text :first_name,{as: :first_name_autocompletable}

    
    # text :username_autocompletable do
    #   username
    # end
    # text :email_autocompletable do
    #   email
    # end
    # text :last_name_autocompletable do
    #   last_name
    # end
    # text :first_name_autocompletable do 
    #   first_name
    # end
    # text :username, :email, :first_name, :last_name
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