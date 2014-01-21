#!/usr/bin/env ruby

data_folder = "data"

color_data = Dir.glob(File.join(data_folder, "color_data", "*.json"))

color_data.each do |cd|
  basename = File.basename(cd)

  if !basename == "all.json"
    recs_file = File.join(data_folder, "recs_data", basename)
    comp_file = File.join(data_folder, "recs_comp_data", basename)
    if !File.exist?(recs_file)
      puts "ERROR: missing: #{basename} recs"
    end
    if !File.exist?(comp_file)
      puts "ERROR: missing: #{basename} comps"
    end
  end
end

puts color_data.length
