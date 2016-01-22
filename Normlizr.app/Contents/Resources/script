#!/usr/bin/ruby

require 'shellwords'

formats = ["mp4", "mov", "flv", "avi", "wmv", "mpg"]

output_folder = File.join(Dir.home,"Desktop","output_folder")

Dir.mkdir(output_folder) unless Dir.exist?(output_folder)

files = ARGV

start_report = []
end_report = []

files.each do |file|
  p file
  start_report << file.split("/").last

  next unless formats.include?(file.split("/").last.split(".").last)

  org_file = Shellwords.escape(file)

  output_path = output_folder+"/"+org_file.split("/").last[0..-5]
  final_filename = org_file.split("/").last[0..-5].gsub(/[^_a-zA-Z0-9\s+]/,'').gsub(/\s+/, '_')
  final_path = output_folder+"/"+ final_filename
  puts output_path

  check_format = `/usr/local/bin/ffprobe -v quiet -show_streams -select_streams v #{org_file} | grep "codec_name"`

  if check_format.strip.split("=").last.downcase == "prores"
    `/usr/local/bin/bs1770gain #{org_file} -ao #{output_folder} -u integrated`
    `/usr/local/bin/ffmpeg -i #{output_path+".mkv"} -f mp4 -pix_fmt yuv420p -vcodec libx264 -acodec libfdk_aac -af "compand=0 0:1 1:-90/-900 -70/-70 -6/-6 0/-6:6:0:0:0" #{final_path+".mp4"}`
  else
    `/usr/local/bin/bs1770gain #{org_file} -ao #{output_folder} -u integrated`
    `/usr/local/bin/ffmpeg -i #{output_path+".mkv"} -f mp4 -vcodec copy -acodec libfdk_aac -af "compand=0 0:1 1:-90/-900 -70/-70 -6/-6 0/-6:6:0:0:0" #{final_path+".mp4"}`
  end
  `rm #{output_path+".mkv"}`
  end_report << file.split("/").last
  puts "######### Finished #{file.split("/").last}! #########"

end

puts "Total Files Dropped: #{start_report.count}"
puts "Following Files were converted: #{end_report}"
puts "Finished converting #{end_report.count} Files"
puts "Following files were not converted: #{start_report - end_report}"
puts "Havent Converted #{start_report.count - end_report.count} Files"
