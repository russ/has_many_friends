Factory.define(:user) do |f|
	f.status 'online'
	f.updated_at DateTime.now
end

Factory.define(:friendship) do |f|
end
