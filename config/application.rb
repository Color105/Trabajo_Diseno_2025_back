require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module ProyrctoDisenoApi
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    # Horario de la app: Buenos Aires
    config.time_zone = "America/Argentina/Buenos_Aires"
    # Guardar en la BD en hora local (Argentina), NO en UTC
    config.active_record.default_timezone = :local

    config.api_only = true
  end
end
