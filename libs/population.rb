module Population
	class Population
		attr_reader :prefecture, :count

		def initialize prefecture, count
			@prefecture = prefecture
			@count = count
		end
	end

	
def get_next_population populations, target
	next_population = nil
	populations.each do |p|
		break if target.to_i > p.count
		next_population = p
	end
	next_population
end

def get_prev_population populations, target
	next_population = nil
	populations.reverse.each do |p|
		break if target.to_i < p.count
		next_population = p
	end
	next_population
end

end
