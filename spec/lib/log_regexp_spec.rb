require 'log_regexp'

RSpec.describe LogRegexp do

  it 'parses zone_change' do
    expect(LogRegexp.match(@logs[:zone_change])).not_to be_nil
    line_data = LogRegexp.match(@logs[:zone_change],:zone_change)
    expect(line_data[:time]).to eq('23:33:09')
    expect(line_data[:name]).to eq('Leper Gnome')
    expect(line_data[:id]).to eq('54')
    expect(line_data[:card_id]).to eq('EX1_029')
    expect(line_data[:player]).to eq('2')
    expect(line_data[:team_from]).to eq('FRIENDLY')
    expect(line_data[:zone_from]).to eq('HAND')
    expect(line_data[:team_to]).to eq('FRIENDLY')
    expect(line_data[:zone_to]).to eq('PLAY')
  end

  it 'parses tag_change' do
    expect(LogRegexp.match(@logs[:tag_change])).not_to be_nil
    line_data = LogRegexp.match(@logs[:tag_change],:tag_change)
    expect(line_data[:time]).to eq '00:05:52'
    expect(line_data[:entity]).to eq 'player'
    expect(line_data[:value]).to eq '1'
  end

  it 'parses game_over' do
    expect(LogRegexp.match(@logs[:game_over])).not_to be_nil
    line_data = LogRegexp.match(@logs[:game_over],:game_over)
    expect(line_data[:time]).to eq '00:16:43'
    expect(line_data[:player]).to eq 'player'
    expect(line_data[:result]).to eq 'WON'
  end

end
