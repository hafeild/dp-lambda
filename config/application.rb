require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Alice
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    ## Should be in megabytes.
    config.MAX_ATTACHMENT_SIZE = 5.megabytes
    config.VERTICAL_MAX_TOATAL_ATTACHMENTS_SIZE = 25.megabytes
    
  end
end
