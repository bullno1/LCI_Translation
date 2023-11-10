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
    value.gsub! /<<([A-Z]+)>>/ do |s|
      keyword = $1
      if keyword === "QUICK"
        "<span size='small' foreground='black' background='#cbac30'> #{keyword} </span>"
      else
        "<span size='small' weight='bold'>#{keyword}</span>"
      end
    end

    # Ability
    value.gsub! /\[([A-Z\(\) ]+)\]/ do |s|
      name = $1
      if ABILITY_COLORS.key?(name)
        "<span background='\##{ABILITY_COLORS[name]}' foreground='white' size='small'> #{name} </span>"
      elsif name.start_with?("SYNC")
        "<small>[#{name}]</small>"
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

  formatted_title = data['title'].map.with_index do |value,index|
    color = data['color'][index]
    if color != 'WILD'
      "{#{color}} #{value}"
    else
      value
    end
  end

  text str: formatted_title, layout: "title" do |embed|
    embed.png key: "{WHITE}", file: "images/white.png", dy: -24, height: 30, width: 30
    embed.png key: "{PURPLE}", file: "images/purple.png", dy: -30, height: 30, width: 30
    embed.png key: "{ORANGE}", file: "images/orange.png", dy: -30, height: 30, width: 30
    embed.png key: "{BLACK}", file: "images/black.png", dy: -30, height: 30, width: 30
    embed.png key: "{BLUE}", file: "images/blue.png", dy: -30, height: 30, width: 30
  end

  rect layout: "title"

  text str: data['id'], layout: "id"

  text str: data['text'], layout: "text" do |embed|
    embed.png key: "{L}", file: "images/legacy.png", dy: -20, width: 28
    embed.png key: "{E}", file: "images/epic.png", dy: -20, width: 25
    embed.png key: "{N}", file: "images/normal.png", dy: -22, width: 18
    embed.png key: "(W)", file: "images/white.png", dy: -22, width: 26, height: 26
    embed.png key: "(P)", file: "images/purple.png", dy: -22, width: 26, height: 26
    embed.png key: "(R)", file: "images/orange.png", dy: -22, width: 26, height: 26
    embed.png key: "(B)", file: "images/black.png", dy: -22, width: 26, height: 26
    embed.png key: "(U)", file: "images/blue.png", dy: -22, width: 26, height: 26
  end

  # Carve out space for atk and def
  rect layout: "atk_box"
  rect layout: "def_box"

  save_pdf sprue: "layouts/textbox_sprue.yml", file: "set1.pdf"
end
