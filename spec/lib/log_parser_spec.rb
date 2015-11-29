require 'log_parser'
Thread.abort_on_exception = true

RSpec.describe LogParser do

  before(:all) do
    open(LOG_FILE, 'w') do |f|
      f.puts 'crash me test!'
    end
  end

  before(:each) do
    @parser = LogParser.new()
  end

  it 'reads log file from the end' do
    logger = Thread.new do
      begin
        parser = LogParser.new(log_file: LOG_FILE)
        timeout(2) do
          parser.tail_f(2)
        end
      rescue TimeoutError
      end
    end
    sleep 0.1
    appender = Thread.new do
      until logger.stop?
        sleep 0.1
      end
      append 'crash me test!'
    end
    expect {
      appender.join
      logger.join
    }.to raise_error(/crash me test!/)
  end

  def append(text=nil)
    text ||= Time.now.to_s
    open(LOG_FILE, 'a') do |f|
      f.puts text
    end
  end

end
