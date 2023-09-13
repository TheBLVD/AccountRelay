require 'datadog/statsd'
require 'ddtrace'
require 'logger'

Datadog.configure do |c|
  c.env = 'production'
  c.version = '2.5.17'
  c.service = 'account-relay'
  c.tracing.enabled = Rails.env.production?
  c.tracing.sampling.default_rate = 0.01
  c.profiling.enabled = Rails.env.production?
  c.appsec.enabled = Rails.env.production?
  c.runtime_metrics.enabled = Rails.env.production?
  # Optionally, you can configure the DogStatsD instance used for sending runtime metrics.
  # DogStatsD is automatically configured with default settings if `dogstatsd-ruby` is available.
  # You can configure with host and port of Datadog agent; defaults to 'localhost:8125'.
  c.runtime_metrics.statsd = Datadog::Statsd.new
end

logger = Logger.new(STDOUT)
logger.progname = 'account-relay'
logger.formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime}][#{progname}][#{severity}][#{Datadog::Tracing.log_correlation}] #{msg}\n"
end
