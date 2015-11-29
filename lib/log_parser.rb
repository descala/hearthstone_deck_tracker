require 'file/tail'
require_relative 'log_regexp'

class LogParser

  attr_accessor :log_file, :players, :match_data,
    :friendly_played, :opposing_played

  def initialize(attributes={})
    @log_file = attributes[:log_file]
    @players  = []
    @friendly_played = {}
    @opposing_played = {}
    @match_data = nil
    @deck = {}
    if attributes[:deck]
      attributes[:deck].each do |card|
        @deck[card] ||= 0
        @deck[card] += 1
      end
      @friendly_played = Hash[@deck.keys.map {|card| [card, 0] }]
    end
  end

  def tail_f(n=nil)
    if @log_file.is_a? Array
      File::Tail::Group[*@log_file].tail do |line|
        parse line
      end
    else
      File::Tail::Logfile.open(@log_file) do |log|
        log.interval = 0.2
        log.backward(0).tail(n) do |line|
          parse line
        end
      end
    end
  end

  def parse(line)
    case line
    when LogRegexp::LOG_REGEX[:zone_change]
      @match_data = LogRegexp.match(line, :zone_change)
      log "zone change: #{match_data[:name]} " +
        "changed from #{match_data[:team_from]} #{match_data[:zone_from]} " +
        "to #{match_data[:team_to]} #{match_data[:zone_to]}"
      process_zone_change(
        match_data[:name],
        match_data[:team_from], match_data[:zone_from],
        match_data[:team_to], match_data[:zone_to]
      )

    when LogRegexp::LOG_REGEX[:tag_change]
      @match_data = LogRegexp.match(line, :tag_change)
      log "adding player #{match_data[:entity]}"
      players << { name: match_data[:entity], id: match_data[:value] }

    when LogRegexp::LOG_REGEX[:game_over]
      @match_data = LogRegexp.match(line, :game_over)
      log "game over: #{match_data[:player]} #{match_data[:result]}"
      player = players.select {|p| p[:name] == match_data[:player] }.first
      if player
        player[:result] = match_data[:result]
      end
      if players.select {|p| p.has_key? :result }.size == 2
        reset
        log "A game has ended"
      end

    when /crash me test!/
      raise line
    else
      #puts "UNKNOWN: #{line}"
      #puts "unknown line"
      # do nothing
    end
    @match_data = nil
  end

  def process_zone_change(card, team_from, zone_from, team_to, zone_to)
    if zone_to == 'PLAY (Hero)'
      players.each do |player|
        if player[:id] == match_data[:player]
          player[:team] = match_data[:team_to]
          log "player #{player[:name]} is #{player[:team]}"
        end
        if players.select {|p| p.has_key? :team }.size == 2
          log "A game has started"
        end
      end
    end

    if players.size > 0
      zone_change = "#{team_from} #{zone_from} > #{team_to} #{zone_to}"
      case zone_change
      when /FRIENDLY HAND > FRIENDLY PLAY.*/,
        'FRIENDLY HAND >  ',
        'FRIENDLY DECK > FRIENDLY SECRET',
        'FRIENDLY DECK > FRIENDLY PLAY'
        @friendly_played[card] ||= 0
        @friendly_played[card] += 1
      when /OPPOSING HAND > OPPOSING PLAY.*/,
        'OPPOSING HAND >  ',
        'OPPOSING DECK > OPPOSING PLAY',
        'OPPOSING SECRET > OPPOSING GRAVEYARD',
        'OPPOSING DECK > OPPOSING GRAVEYARD'
        @opposing_played[card] ||= 0
        @opposing_played[card] += 1
      when 'OPPOSING PLAY > OPPOSING HAND'
        if @opposing_played.has_key? card
          @opposing_played[card] -= 1
        end
      when 'OPPOSING DECK >  '
        if card
          @opposing_played[card] ||= 0
        end
      end
      print_played_cards
    end
  end

  def reset
    @players = []
    @friendly_played = Hash[@deck.keys.map {|card| [card, 0] }]
    @opposing_played = {}
  end

  def log(msg)
    #if @match_data
    #  puts "#{@match_data[:time]}: #{msg}"
    #else
    #  puts msg
    #end
  end

  def print_played_cards
    puts `clear`
    puts "Friendly played cards:"
    if @deck
      @friendly_played.each do |card, num|
        puts "  #{num} of #{@deck[card] || ' '} #{card}"
      end
    else
      @friendly_played.each do |card, num|
        puts "  #{num} #{card}"
      end
    end
    puts
    puts "Opposing played cards:"
    @opposing_played.each do |card, num|
      puts "  #{num} #{card}"
    end
  end

end
