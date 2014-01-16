#!/usr/bin/env ruby

require 'json'
require 'csv'

require 'time'

input_filename = "test_male_recs.txt"
# input_filename = "test.tsv"

output_dir = "../data/recs_data"
system("mkdir -p #{output_dir}")

def clean_name name
  name.gsub(/\(.*\)/,"").strip()
end

def pull_out_color csv
  col = {"color_name" => clean_name(csv["color_name"]), "color_id" => csv["color_id"], 'recs' => []}
  col
end

def add_rec color, csv
  pur = {"rms_sku" => csv["rms_sku_id"].strip, "style_id" => csv["web_style_id"].strip,
         "product_url" => csv["product_url"], "image_url" => csv["sku_img_url"].gsub("thumbnail", "Medium"), "web_url" => csv["web_style_hostd_url"]
  }

  color['recs'] << pur
end

def weight color
  color["grayscale"] ? 0.2 : 1.0
end

users = {}

CSV.foreach(input_filename, { :col_sep => "\t", :headers => true }) do |csv|
  color_id = csv["color_id"]

  if !users[csv["CUST_KEY"]]
    users[csv["CUST_KEY"]] = {"id" => csv["CUST_KEY"], "colors" => {}}
    puts csv["CUST_KEY"]
  end

  if !users[csv["CUST_KEY"]]["colors"][color_id]
    users[csv["CUST_KEY"]]["colors"][color_id] = pull_out_color(csv)
    puts color_id
  end

  if users[csv["CUST_KEY"]]["colors"][color_id]['recs'].length < 20
    add_rec(users[csv["CUST_KEY"]]["colors"][color_id], csv)
  end
end

users.each do |user_key, user_data|
  user_id = user_data['id']
  output_filename = File.join(output_dir, "#{user_id}.json")
  File.open(output_filename, 'w') do |file|
    file.puts JSON.pretty_generate(JSON.parse(user_data.to_json))
  end
end

# all_filename = File.join(output_dir, "all.json")
# File.open(all_filename, 'w') do |file|
#   file.puts JSON.pretty_generate(JSON.parse(all.to_json))
# end
