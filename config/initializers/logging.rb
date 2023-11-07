Rails.logger = ActiveSupport::TaggedLogging.new(Appsignal::Logger.new('rails'))
