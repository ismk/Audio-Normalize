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

  new_filename = Shellwords.escape(file)

  final_filename = output_folder+"/"+new_filename.split("/").last[0..-5]
  puts final_filename

  check_format = `/usr/local/bin/ffprobe -v quiet -show_streams -select_streams v #{new_filename} | grep "codec_name"`

  if check_format.strip.split("=").last.downcase == "prores"
    `/usr/local/bin/bs1770gain #{new_filename} -ao #{output_folder} -u integrated`
    `/usr/local/bin/ffmpeg -i #{final_filename+".mkv"} -f mp4 -pix_fmt yuv420p -vcodec libx264 -acodec libfdk_aac -af "compand=0 0:1 1:-90/-900 -70/-70 -6/-6 0/-6:6:0:0:0" #{final_filename+".mp4"}`
  else
    `/usr/local/bin/bs1770gain #{new_filename} -ao #{output_folder} -u integrated`
    `/usr/local/bin/ffmpeg -i #{final_filename+".mkv"} -f mp4 -vcodec copy -acodec libfdk_aac -af "compand=0 0:1 1:-90/-900 -70/-70 -6/-6 0/-6:6:0:0:0" #{final_filename+".mp4"}`
  end
  `rm #{final_filename+".mkv"}`
  end_report << file.split("/").last
  puts "######### Finished #{file.split("/").last}! #########"
end

puts "Total Files Dropped: #{start_report.count}"
puts "Following Files were converted: #{end_report}"
puts "Finished converting #{end_report.count} Files"
puts "Following files were not converted: #{start_report - end_report}"
puts "Havent Converted #{start_report.count - end_report.count} Files"
