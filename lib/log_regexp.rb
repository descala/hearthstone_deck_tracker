class LogRegexp

  COMMON_REGEX = /D (?<time>[^\.]*).*/
  LOG_REGEX = {
    zone_change: /#{COMMON_REGEX} ZoneChangeList.ProcessChanges\(\) - id=\d* local=.* \[name=(?<name>.*) id=(?<id>\d*) zone=.* zonePos=\d* cardId=(?<card_id>.*) player=(?<player>\d)\] zone from ?(?<team_from>FRIENDLY|OPPOSING)? ?(?<zone_from>.*)? -> ?(?<team_to>FRIENDLY|OPPOSING)? ?(?<zone_to>.*)?/,
    tag_change: /#{COMMON_REGEX} GameState\.DebugPrintPower\(\) - TAG_CHANGE Entity=(?<entity>.*) tag=PLAYER_ID value=(?<value>.)/,
    game_over: /#{COMMON_REGEX} GameState\.DebugPrintPower\(\) - TAG_CHANGE Entity=(?<player>.*) tag=PLAYSTATE value=(?<result>LOST|WON|TIED)/

  }

  def self.match(line, key=nil)
    if key and line =~ LOG_REGEX[key]
      matchdata = line.chomp.match(LOG_REGEX[key])
      matchdata = Hash[
        matchdata.names.zip(matchdata.captures.collect {|c|
          c.nil? ? c : c.chomp
        })
      ].with_indifferent_access
      matchdata
    elsif key.nil?
      line =~ Regexp.union(LOG_REGEX.values)
    end
  end

end
