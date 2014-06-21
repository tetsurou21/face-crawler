
mapping_file = ARGV[0]

open(mapping_file) do |f|
  f.each_line do |line|
    line.chomp!
    id, * = line.split("\t")
    if not File.exists? "img/#{id}/point.txt"
      next
    end
    open("img/#{id}/point.txt") do |g|
      point = g.read
      point.chomp!
      puts "#{line}\t#{point}"
    end
  end
end
