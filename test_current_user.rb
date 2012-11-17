require "sqlite3"
=begin class Current_user
	def initialize
		begin
			db = SQLite3::Database.open 'resume_builder.db'
			db.execute "DROP TABLE IF EXISTS Current_User"
			db.execute "CREATE TABLE IF NOT EXISTS Current_User(id INTEGER PRIMARY KEY, Current_user TEXT)"
		rescue Exception => e
			puts e
		ensure
			db.close if db
		end
	end

	def getUser
		@login
	end

	def setUser=(email)
		@login = email
	end
end

user = Current_user.new
user.setUser = "asd"
x = user.getUser()
puts x
=end

begin
	db = SQLite3::Database.open 'resume_builder.db'
	x = db.execute "SELECT Title FROM Resume WHERE 'asdf' = Resume.User"
	puts x
rescue Exception => e
ensure
	db.close if db
end