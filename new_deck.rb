require 'readline'
require_relative 'lib/card_db'

CARDS = CardDb.new.all.collect {|card| card[:name] }.sort

comp = proc { |s| CARDS.grep(/^#{Regexp.escape(s)}/i) }

Readline.completion_append_character = ""
Readline.completer_word_break_characters = "\n"
Readline.completion_proc = comp

cards = []
while cards.size < 30
  line = Readline.readline('> ', true)
  cards << line
end

puts "done! card list:"
puts '-----------'
puts cards.join("\n")
puts '-----------'
