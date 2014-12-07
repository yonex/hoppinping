require 'bundler'
Bundler.require

# rubyコードに変更があった時、反映に再起動が不要、本当に便利 (gem 'sinatra-contrib')
register Sinatra::Reloader
set :haml, :format => :html5, :escape_html => true
# 起動オプションで -e productionってやるといい
#set :environment => :production

require 'open-uri'
require 'rexml/document'
require 'date'
require 'time'
require 'csv'

require './libs/video'
include Video
require './libs/population'
include Population

redis = Redis.new
cache = VideoCache.new redis, 300
videoRepository = VideoRepository.new cache

# 
configure :production do
  not_found do
    @error_message = "ページが見つからない"
    haml :error
  end

  error do
    @error_message = "謎のエラー"
    haml :error
  end
end

video_ids_from_file = CSV.read('./data/videos.csv').map do |row|
	{
		:episode_id => row[0], # 第何羽
		:id => row[1]          # ニコニコ動画上のID
	}
end

populations = CSV.read('./data/population.csv').map do |row|
	Population::Population.new(row[0], row[1].to_i)
end

hitokoto_list = CSV.read('./data/hitokoto.csv').map { |row| row[0] }

get '/' do
	@videos = video_ids_from_file.map do |video|
		videoRepository.get video[:id]
	end
	@total = @videos.map do |video| video.view_counter end.inject do |a, b| a + b end
	@next_population = get_next_population populations, @total
	@prev_population = get_prev_population populations, @total
	@hitokoto = hitokoto_list.sample
	haml :index
end

class Integer
	def insert_commas
		self.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
	end
end
