require 'fileutils'

open('img/mapping.txt', 'w') do |file|
  Dir.glob('img_old/*.jpg').each_with_index do |path, i|
    puts "path = #{path}"
    if path !~ %r|([^/]+)\.jpg|
      next
    end
    name = $1
    id = sprintf('%05d', i)
    file.puts "#{id}\t#{name}"
    if not File.exists? "img/#{id}"
      FileUtils.mkdir("img/#{id}")
    end
                      
    new_path = sprintf "img/#{id}/orig.jpg"
    FileUtils.cp(path, new_path)
  end
end
