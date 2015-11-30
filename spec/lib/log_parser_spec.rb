require 'log_parser'
Thread.abort_on_exception = true

RSpec.describe LogParser do

  before(:all) do
    open(LOG_FILE, 'w') do |f|
      f.puts 'crash me test!'
    end
  end

  before(:each) do
    @parser = described_class.new()
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

  it 'parses zone_change' do
    @parser.players = [
      { name: 'player', id: '1' },
      { name: 'opponent', id: '2' }
    ]
    expect {
      @parser.parse @logs[:zone_change]
    }.to output(/  1 Leper Gnome/).to_stdout
    @parser.deck = { 'Leper Gnome' => 2 }
    expect(@parser.friendly_played.size).to eq(1)
    expect(@parser.friendly_played['Leper Gnome']).to eq(1)
    expect(@parser.opposing_played.size).to eq(0)
    expect {
      @parser.parse @logs[:zone_change]
    }.to output(/2 of 2 Leper Gnome/).to_stdout
    # 2 of 2 since we already played one Leper Gnome
    expect(@parser.friendly_played.size).to eq(1)
    expect(@parser.friendly_played['Leper Gnome']).to eq(2)
    expect(@parser.opposing_played.size).to eq(0)
  end

  it 'parses tag_change' do
    @parser.parse @logs[:tag_change]
    expect(@parser.players.size).to eq(1)
  end

  it 'parses game_over' do
    @parser.players = [
      { name: 'player', id: '1' },
      { name: 'opponent', id: '2' }
    ]
    @parser.parse @logs[:game_over]
    expect(@parser.players.select {|p| p[:name] == 'player' }.size).to eq(1)
    player = @parser.players.select {|p| p[:name] == 'player' }.first
    expect(player[:result]).to eq('WON')
  end

  it 'accepts deck on initialize' do
    parser = described_class.new(
      deck: ['Leper Gnome', 'Leper Gnome', 'Argent Squire']
    )
    expect(parser.deck).to eq({ 'Leper Gnome' => 2, 'Argent Squire' => 1 })
  end

  it 'parses zone_change with PLAY (Hero)' do
    @parser.players = [
      { name: 'player', id: '1', team: 'FRIENDLY' },
      { name: 'opponent', id: '2' },
    ]
    expect {
      @parser.parse @logs[:zone_change2]
    }.to output(/Friendly played cards:/).to_stdout
    expect(@parser.players.size).to eq(2)
    expect(@parser.players.select {|p| p.has_key? :team }.size).to eq(2)
    expect(@parser.players[1][:team]).to eq('OPPOSING')
  end

  it 'resets game on game_over' do
    @parser.players = [
      { name: 'player', id: '1', result: 'WON'},
      { name: 'opponent', id: '2', result: 'LOST' }
    ]
    @parser.deck = { 'Leper Gnome' => 2 }
    expect(@parser.friendly_played.size).to eq(0)
    expect(@parser.opposing_played.size).to eq(0)
    @parser.parse @logs[:game_over]
    expect(@parser.players.size).to eq(0)
    expect(@parser.friendly_played.size).to eq(1)
    expect(@parser.friendly_played['Leper Gnome']).to eq(0)
    expect(@parser.opposing_played.size).to eq(0)
  end

end
