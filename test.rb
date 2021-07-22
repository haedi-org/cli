arr = [nil, [], "test", ""]

puts arr.include?(nil).inspect
puts arr.include?([]).inspect
puts arr.include?("apple").inspect
puts arr.include?(false).inspect