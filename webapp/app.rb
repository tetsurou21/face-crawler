require 'sinatra'

set :public_folder, File.dirname(__FILE__) + '/public'

def get_names(n) 
  gamefile = File.dirname(__FILE__) + "/game/#{n}.txt"
  names = []
  open(gamefile) do |input|
    input.each do |name|
      names << name.chomp
    end
  end
  names
end

get '/' do
  erb :index
end

post '/game' do
  name = params[:name]
  file = params[:file]

  logger.info("name = #{name}, file = #{file}")

  message = nil
  if file
    save_path = File.dirname(__FILE__) + "/public/img/people/#{name}.jpg"
    logger.info("save_path = #{save_path}")
    open(save_path, "wb") do |output|
      output.write file[:tempfile].read
    end
    message = "#{name}を探せを作成しました"
  else
    message = "作成できませんでした"
  end

  max_num = Dir.entries("./game").select do |entry|
    entry =~ /\d+\.txt/
  end
  .map do |path|
    path.gsub('.txt', '').to_i
  end
  .max()

  logger.info("max_num = #{max_num}")

  names = Dir.entries("./public/img/people").shuffle.take(8).map do |entry|
    entry.gsub('.jpg', '')
  end

  names.unshift name

  game_file = "./game/#{max_num+1}.txt"

  open(game_file, "w") do |output|
    names.each do |n|
      output.puts n
    end
  end

  erb :game_create, :locals => {:message => message}
  redirect "/game/#{max_num+1}"
end

get '/game/:n' do |n|
  names = get_names(n)
  answer = names[0]
  cands = names.shuffle
  name_i = 0
  cands.each_with_index do |name, i|
    if name == answer
      name_i = i+1
      break
    end
  end
  logger.info("cands = #{cands}, answer = #{name_i}")
  answerfile = File.dirname(__FILE__) + "/answer/#{n}.txt"
  open(answerfile, "w") do |output|
    output.write(name_i)
  end

  erb :game, :locals => {:names => cands}
end

get '/game/:m/answer/:n' do |m,n|
  answerfile = File.dirname(__FILE__) + "/answer/#{m}.txt"
  name_i = nil
  open(answerfile) do |input|
    name_i = input.gets
  end
  logger.info("name_i=#{name_i}")
  logger.info("n = #{n}")

  headers 'Content-Type' => 'application/json'
  if (name_i.to_i) == (n.to_i)
    'true'
  else
    'false'
  end
end
