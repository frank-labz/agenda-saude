# frozen_string_literal: true

require_relative 'boot'

require 'rails'

# action_cable/engine
# action_mailbox/engine
# action_text/engine
# active_storage/engine
%w[
  action_controller/railtie
  action_mailer/railtie
  action_view/railtie
  active_record/railtie
  rails/test_unit/railtie
  sprockets/railtie
].each do |railtie|
  require railtie
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TemplateRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Application configuration
    config.x.use_ssl = false # due to Heroku taking care of that
    config.x.app_url = ENV.fetch("APP_URL", "https://www.vacinajoinville.com.br")
    config.x.time_zone = "Brasilia"
    config.x.slack_webhook_url = ENV.fetch("SLACK_WEBHOOK_URL", "")
    config.x.backtrace = ENV.fetch("BACKTRACE", "")
    config.x.second_dose_interval = ENV.fetch("SECOND_DOSE_INTERVAL", "4")
    config.x.late_patient_tolerance_minutes = ENV.fetch("LATE_PATIENT_TOLERANCE_MINUTES", "10")
    config.x.eaerly_patient_warning_minutes = ENV.fetch("EARLY_PATIENT_WARNING_MINUTES", "30")
    config.x.slots_window_in_days = ENV.fetch("SLOTS_WINDOW_IN_DAYS", "7")
    config.x.timeslotgen_execution_hour = ENV.fetch("TIMESLOTGEN_EXECUTION_HOUR", "22") # Hour of the day the time slot generation worker will run
    config.x.max_appointment_days_ahead = ENV.fetch("MAX_APPOINTMENT_DAYS_AHEAD", "3") # Max number of days the user can see ahead when listing time slots
    config.x.sentry_dsn = ENV.fetch('SENTRY_DSN', '')

    # https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoload-paths
    config.autoload_paths += [
      Rails.root.join('app', 'services'),
      Rails.root.join('app', 'validators')
    ]

    config.action_controller.default_url_options = {
      protocol: Rails.configuration.x.use_ssl ? "https" : "http",
      host: Rails.configuration.x.app_url
    }

    config.after_initialize do
      Rails.application.routes.default_url_options = {
        protocol: Rails.configuration.x.use_ssl ? "https" : "http",
        host: Rails.configuration.x.app_url
      }
    end

    config.generators do |generator|
      generator.test_framework :rspec, fixtures: false
      generator.fixture_replacement :factory_bot
      generator.factory_bot dir: 'spec/factories', suffix: 'factory'
    end

    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.{rb,yml}')]
    config.i18n.available_locales = %w[pt-BR en]
    config.i18n.default_locale = :'pt-BR'
    config.time_zone = Rails.application.secrets.time_zone

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    config.action_controller.include_all_helpers = true
  end
end
