require 'json'

class CardDb

  DB_FILE=File.join(File.dirname(__FILE__),'..','ext','AllSets.json')

  def initialize
    f = File.open(DB_FILE)
    @cards = JSON(f.read)#.values.flatten
    f.close
  end

  def find(id)
    @cards.first {|card| card['id'] }
  end

  def all
    @cards
  end

end
