# rollup per-page lists to per-site and per-scrape lists

def rollup path, part, file
	hash = {}
	Dir.glob("#{path}/#{part}/#{file}") do |filename|
		File.open(filename, 'r').each do |line|
			hash[line] = true
		end
	end
	if hash.empty?
		File.delete("#{path}/#{file}") if File.exist?("#{path}/#{file}")
	else
		File.open("#{path}/#{file}", 'w') do |file|
			file.puts hash.keys.sort
		end
	end
end

def sites file
	puts file
	Dir.glob("sites/*") do |dirname|
		rollup dirname, 'pages/*/', file
	end
	rollup '.', 'sites/*', file
end

sites 'links.txt'
sites 'sites.txt'
sites 'words.txt'
sites 'items.txt'
sites 'plugins.txt'
