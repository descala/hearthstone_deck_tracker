#!/usr/bin/env ruby
require_relative 'lib/log_parser'
require 'active_support/core_ext/hash/indifferent_access'

LOG_DIR='/home/tictacbum/.local/share/wineprefixes/hearthstone/' +
  'drive_c/Program Files/Hearthstone/Logs'
LOG=[
  "#{LOG_DIR}/Power.log",
  "#{LOG_DIR}/Zone.log",
]
puts "starting Hearthstone deck tracker"

begin
  log_parser = LogParser.new(
    log_file: LOG,
  )
  log_parser.tail_f

rescue Interrupt
  puts
end
puts "bye!"
