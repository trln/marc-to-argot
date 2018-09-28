describe LoggingAdapter do
  it 'initializes normally' do
    Yell.new do |l|
      l.adapter :logging_adapter
    end
    Yell::Logger.new.info "Hi there"
  end
  
  it 'initializes with :stderr appender' do
    Yell.new do |l|
      l.adapter :logging_adapter, appender: :stderr
    end
    Yell::Logger.new.info "Hi there"
  end
end
