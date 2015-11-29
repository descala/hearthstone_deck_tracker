#!/usr/bin/env ruby
require_relative 'lib/log_parser'
require 'active_support/core_ext/hash/indifferent_access'
require 'optparse'
require 'json'

if File.exist? 'config.json'
  options = JSON.load(File.read('config.json')).with_indifferent_access
end
options ||= {}

OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-p", "--log-path PATH", "Path to Hearthstone log dir") do |v|
    options[:log_path] = v
  end

end.parse!

log_files = [
  "#{options[:log_path]}/Power.log",
  "#{options[:log_path]}/Zone.log",
]

log_files.select {|f| !File.exist? f }.each do |f|
  puts "Could not find log file, check log path #{f}"
  exit 1
end

begin
  puts "starting Hearthstone deck tracker"

  log_parser = LogParser.new(
    log_file: log_files,
  )
  log_parser.tail_f

rescue Interrupt
  puts "bye!"
end
