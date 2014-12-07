module Video
	class Video
		attr_reader :id, :title, :view_counter, :last_res_body, :thumbnail, :comment_num, :mylist_counter

		def initialize id, title, view_counter, last_res_body, thumbnail, comment_num, mylist_counter
			@id = id
			@title = title
			@view_counter = view_counter
			@last_res_body = last_res_body
			@thumbnail = thumbnail
			@comment_num = comment_num
			@mylist_counter = mylist_counter
		end

		def to_hash
			{
				"id" => @id.to_i,
				"title" => @title,
				"view_counter" => @view_counter.to_i,
				"last_res_body" => @last_res_body,
				"thumbnail" => @thumbnail,
				"comment_num" => @comment_num,
				"mylist_counter" => @mylist_counter
			}
		end
	end

	class VideoRepository
		def initialize cache
			@cache = cache
		end

		def get id
			@cache.get_video id do
				# キャッシュがなければ、新鮮なデータを取得
				uri = "http://ext.nicovideo.jp/api/getthumbinfo/#{id}"
				response = REXML::Document.new(open(uri)).elements['nicovideo_thumb_response']
				if response.attributes['status'] != 'ok'
					raise "failed to fetch video: #{id}"
				else
					data = response.elements['thumb']
					Video.new(
						id.to_i,
						data.elements['title'].text,
						data.elements['view_counter'].text.to_i,
						data.elements['last_res_body'].text,
						data.elements['thumbnail_url'].text,
						data.elements['comment_num'].text.to_i,
						data.elements['mylist_counter'].text.to_i
					)
				end
			end
		end
	end

	class VideoCache
		def initialize redis, lifetime
			@redis = redis
			@lifetime = lifetime
		end

		# &block には、Video を返すブロックを渡す
		def get_video id, &block
			video = @redis.hgetall "video:#{id}"
			if video.empty?
				# キャッシュがなければ渡されたブロックを実行して、キャッシュする
				# (参考) [Ruby] ブロックとProcをちゃんと理解する - Qiita http://qiita.com/kidachi_/items/15cfee9ec66804c3afd2
				video = block.call
				@redis.mapped_hmset "video:#{video.id}", video.to_hash
				@redis.expire "video:#{video.id}", @lifetime
				video
			else
				Video.new(
					video['id'].to_i,
					video['title'],
					video['view_counter'].to_i,
					video['last_res_body'],
					video['thumbnail'],
					video['comment_num'].to_i,
					video['mylist_counter'].to_i
				)
			end
		end
	end
end
