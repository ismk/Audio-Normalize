#!/usr/bin/env ruby


@codecs = {
  "flv"=>"-codec:v libx264 -crf 19",
  "mov"=>"-c:v copy -c:a h264 -acodec aac -strict -2",
  "avi"=>"-c:v copy -c:a libmp3lame -q:a 2",
  "mp4"=>"-c:v copy -b:a 192k -c:a aac -strict -2",
  "wmv"=>"-codec:v libx264 -crf 23 -c:a libfaac -q:a 100"
}

@separator = "----------------------------------------------------\n"





def get_difference(matches)
  max_volume = matches[0].split(":").last[1..-5]

  max_volume = ("%.2f" % max_volume).to_f
  puts "this is the max volume -> #{max_volume}"
  puts @separator

  difference = -(max_volume + 6.0)
  difference = ("%.2f" % difference).to_f

  return difference
end

def conversion(path)

  filename_change_path = path + "/"

    system("mkdir #{path}/original_videos")
    system("mkdir #{path}/converted_videos")

  Dir.chdir(path)

  files = Dir.glob("*.{mov,mp4,flv,avi,wmv}")

  puts "following files will be processed: "
  puts files
  puts @separator



  files.each do |file|

    array_of_filenames = []
    counter = 0

    if file.include? " "
      old_filename = file.dup
      file.gsub!(/\s+/, '_')
      file.gsub!("(", '')
      file.gsub!(")", '')
      system("mv '#{filename_change_path+old_filename}' '#{filename_change_path+file}'")
    end


    system("cp #{file} #{path}/original_videos/")

    puts "this is the file being processed now -> #{file}"
    puts @separator

    orginial_filename = file[0..-5]
    filename = file[0..-5]
    ext = file[-3..-1]

    system("ffmpeg -i '#{file}' -af 'volumedetect' -f null - >'#{path}/#{filename}.txt' 2>&1")

    # read_analysis = File.readlines("#{path}/#{filename}.txt")
    # getMaxVolume = read_analysis.select { |l| l[/max_volume.*$/] }

    getMaxVolume = File.readlines("#{path}/#{filename}.txt").select { |l| l[/max_volume.*$/] }
    difference = get_difference(getMaxVolume)

    puts "this is the extension of the video file -> #{ext}"
    puts @separator

    puts "this is the difference that needs to be added -> #{difference}"
    puts @separator

    array_of_filenames << "#{file}"



    until (difference > -0.4 && difference < 0.4)
      break if (counter > 10)


      last_file = array_of_filenames.last

      puts "this is the last file  ---> \n #{last_file}"
      ext = last_file[-3..-1]
      last_file = last_file[0..-5]

      puts("ffmpeg -i '#{last_file}.#{ext}' -af 'volume=#{difference}dB' #{@codecs[ext]} '#{path}/#{filename}#{counter}.mp4'")
      system("ffmpeg -i '#{last_file}.#{ext}' -af 'volume=#{difference}dB' #{@codecs[ext]} '#{path}/#{filename}#{counter}.mp4'")


      array_of_filenames << "#{filename}#{counter}.mp4"
      puts @separator
      puts("ffmpeg -i '#{last_file}.#{ext}' -af 'volumedetect' -f null - >'#{path}/#{filename}#{counter}.txt' 2>&1")
      system("ffmpeg -i '#{last_file}.#{ext}' -af 'volumedetect' -f null - >'#{path}/#{filename}#{counter}.txt' 2>&1")

      getMaxVolume = File.readlines("#{path}/#{filename}#{counter}.txt").select { |l| l[/max_volume.*$/] }
      difference = get_difference(getMaxVolume)

      if array_of_filenames.length > 1
        system("rm #{array_of_filenames.first}")
        system("rm #{array_of_filenames.first[0..-5]}.txt")
        array_of_filenames.shift
      end

      counter += 1

    end

    system("mv #{array_of_filenames.last} #{orginial_filename}.mp4")
    system("mv #{orginial_filename}.mp4 #{path}/converted_videos/")
    system("mv *.txt #{path}/converted_videos/")

    #     puts("ffmpeg -i '#{file}' -af 'volume=#{difference}dB' #{@codecs[ext]} '#{path}/converted_videos/#{filename}.mp4'")
    #     puts @separator

    #     system("ffmpeg -i '#{file}' -af 'volume=#{difference}dB' #{@codecs[ext]} '#{path}/converted_videos/#{filename}.mp4'")

    #     puts("ffmpeg -i '#{file}' -af 'volumedetect' -f null - >'#{path}/second_analysis/#{filename}-output.txt' 2>&1")
    #     system("ffmpeg -i '#{path}/converted_videos/#{filename}.mp4' -af 'volumedetect' -f null - >'#{path}/second_analysis/#{filename}-output.txt' 2>&1")

    #     getMaxVolume = File.readlines("#{path}/second_analysis/#{filename}-output.txt")
    #     matches = getMaxVolume.select { |l| l[/max_volume.*$/] }

    #     puts matches
    #     puts @separator
  end
end


path = File.expand_path(File.join(File.dirname(__FILE__)))

conversion(path)

# conversion(path+"/"+"converted_videos")




# all_txts = Dir.glob("*.txt")


# p all_txts

# all_txts.each do |txt|
#   path = Dir.pwd + "/" + txt
#   p path
#   system("rm '#{txt}'")
# end
