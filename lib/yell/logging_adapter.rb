require 'yell'
require 'logging'

# Adapter that allows Yell to use logging
# gem.  This adapter always creates a logger
# that outputs to STDERR
#
# https://github.com/TwP/logging
#
# A primary benefit of using this adapter is that it gives
# access to a mapped diagnostic context (MDC), which is a shared
# hash that can store pieces of info that are output in log mesages.
# To set a value in the MDC:
# `Logging.mdc['record_id'] = ids.first`
# To unset it:
# `Logging.mdc.remove('record_id')`
# To clear the MDC:
#  `Logging.mdc.clear``
#
# The default pattern for output messages is
# `"[%d] %-5l <%X{record_id}#[%X{field}]>: %m \n")`
# (timestamp, level, record_id + '#' + field from MDC`, message)
# X{foo} outputs values from the MDC
class LoggingAdapter < Yell::Adapters::Base
  include Yell::Helpers::Base
  include Yell::Helpers::Formatter

  attr_reader :logger, :appender

  DEFAULT_PATTERN = "[%d] %-5l <%X{record_id}#[%X{field}]>: %m \n".freeze

  DEFAULT_DATE_PATTERN = '%Y-%m-%dT%H:M:%s.%s'.freeze

  setup do |options|
    @pattern = options.fetch(:pattern, DEFAULT_PATTERN)
    @date_pattern = options.fetch(:date_pattern, DEFAULT_DATE_PATTERN)
    appender_name = options.fetch(:appender, :stderr)
    layout = Logging.layouts.pattern(
      pattern: @pattern,
      date_pattern: @date_pattern
    )
    @appender = case appender_name
                when :stderr
                  Logging.appenders.stderr('stderr', layout: layout)
                when :stdout
                  Logging.appenders.stdout('stdout', layout: layout)
                when :string_io
                  Logging.appenders.string_io.new('string_io')
                else
                  Logging.appenders.stderr('stderr', layout: layout)
                end

    if @logger.nil?
      @logger = Logging::Logger[options.fetch('logger_name', 'mta')]
      @logger.add_appenders(@appender)
      @logger.level = options.fetch(:level, :warn)
    end
  end

  write do |event|
    lvl = event.level
    case lvl
    when 0 # lvl.at?(:debug)
      @logger.debug(event.messages.join(' '))
    when 1 # lvl.at?(:info)
      @logger.info(event.messages.join(' '))
    when 2 # lvl.at?(:warn)
      @logger.warn(event.messages.join(' '))
    when 3 # lvl.at?(:error)
      @logger.warn(event.messages.join(' '))
    when 4 # lvl.at?(:fatal)
      @logger.warn(event.messages.join(' '))
    else
      @logger.warn("Unhandled level #{event.level.inspect} : #{event.messages}")
    end
  end

  private

  def map_event(yell_event)
    Logging::LogEvent.new(@logger, yell_event.level, yell_event.messages, false)
  end
end

Yell::Adapters.register :logging_adapter, LoggingAdapter
