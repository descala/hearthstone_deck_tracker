require 'nokogiri'

class CardDb

  DB_FILE=File.join(File.dirname(__FILE__),'..','ext','cardDB.enUS.xml')

  def initialize
    f = File.open(DB_FILE)
    @cards = Nokogiri::XML(f)
    f.close
  end

  def find(id)
    node = @cards.xpath("//Card[CardId='#{id}']")
    xml_to_card(node)
  end

  def xml_to_card(node)
    {
      id:         node.xpath("CardId").text,
      name:       node.xpath("Name").text,
      card_set:   node.xpath("CardSet").text,
      rarity:     node.xpath("Rarity").text,
      card_type:  node.xpath("Type").text,
      attack:     node.xpath("Attack").text,
      health:     node.xpath("Health").text,
      cost:       node.xpath("Cost").text,
      durability: node.xpath("Durability").text,
      card_class: node.xpath("Class").text,
      faction:    node.xpath("Faction").text,
      text:       node.xpath("Text").text.gsub(/\n/,'\n')
    }
  end

  def all
    @cards.xpath("//Card").collect do |node|
      xml_to_card(node)
    end
  end

end
