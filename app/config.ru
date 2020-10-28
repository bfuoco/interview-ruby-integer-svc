require "auto_reloader"

AutoReloader.activate reloadable_paths: [__dir__], delay: 1
run ->(env) {
  AutoReloader.reload! do |unloaded|
    ActiveSupport::Dependencies.clear if unloaded && defined?(ActiveSupport::Dependencies)

    require_relative "app"

    App.call env
  end
}