require 'squib'
require_relative 'version'

# Sample image size (px): 573 x 800
# Measured text box size (px): 573 x 256
# Standard sized card size (in): 2.5 x 3.5
# 90x86

ABILITY_COLORS = {
  'CB' => 'ff0000',
  'ENT' => '00ab8c',
  'ATK' => 'e92c1a',
  'DEF' => '0d70bd',
  'DEV' => '91341f',
  'RETREAT' => '737478',
  'ACT' => 'ffad2e',
  'CONT' => '3dbeeb',
  'AUTO' => '642a96',
  'BOOKMARK' => 'ece165',
}

data = Squib.csv file: 'data/set1.csv' do |header, value|
  case header
  when 'text'
    value.gsub! '\n', "\n"
    # Keywords
    value.gsub! /<<([A-Z]+)>>/, "<span size='small' weight='bold'>\\1</span>"
    # Ability
    value.gsub! /\[([A-Z]+)\]/ do |s|
      name = $1
      if ABILITY_COLORS.key?(name)
        "<span background='\##{ABILITY_COLORS[name]}' foreground='white' size='small'> #{name} </span>"
      else
        "<small>#{name}</small>"
      end
    end
    value
  else
    value
  end
end

Squib::Deck.new(cards: data['id'].size, width: '2.5in', height: '1.05in') do
  use_layout file: "layouts/textbox.yml"

  text str: data['title'], layout: "title"
  rect layout: "title"

  text str: data['text'], layout: "text" do |embed|
    embed.png key: "{L}", file: "images/legacy.png", dy: -20, width: 28
  end

  # Carve out space for atk and def
  rect layout: "atk_box"
  rect layout: "def_box"

  save_pdf sprue: "layouts/textbox_sprue.yml", file: "sprue.pdf"
end
