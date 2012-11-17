require 'sinatra'
require 'sqlite3'
#set :session_secret, ENV["SESSION_KEY"] || 'too secret'
enable :sessions
=begin
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'data_mapper'


DataMapper.setup :default, "sqlite://#{Dir.pwd}/resume_builder.db"
#If there is a error while saving, error.
DataMapper::Model.raise_on_save_failure = true 

class User
	include DataMapper::Resource
	property :id 				, Serial
	property :email_address		, String
	property :password			, String
	validates_uniqueness_of :email_address

	has 1, :resume
end


class Resume
	include DataMapper::Resource
	property :id 				, Serial
	property :title				, String

	belongs_to :user
end
#DataMapper.finalize shiuld be decakred after declaring all models
#DataMapper.auto_upgrade! will detect changes in the model and update/add a new row to the table
DataMapper.finalize
DataMapper.auto_upgrade!
=end


class User
	def initialize
		begin
			db = SQLite3::Database.open "resume_builder.db"
			db.execute "CREATE TABLE IF NOT EXISTS Users(id INTEGER PRIMARY KEY AUTOINCREMENT, Email TEXT UNIQUE, Password TEXT NOT NULL,
				CHECK(Email <> ''), CHECK(Password <> ''))"
			
		rescue Exception => e
			puts "Exception occured"
			puts e
		ensure
			db.close if db
		end
	end
end

class Resume
	def initialize
		begin
			db = SQLite3::Database.open 'resume_builder.db'
			db.execute "CREATE TABLE IF NOT EXISTS Resume(id INTEGER PRIMARY KEY AUTOINCREMENT, User TEXT, Title TEXT, First_name TEXT, Last_name TEXT,
				Email TEXT, Home_address TEXT, City TEXT, State TEXT, Zip_code INTEGER, Telephone_number INTEGER, School TEXT,
				School_city TEXT, School_state TEXT, Degree TEXT, Graduation_date TEXT, Major TEXT, GPA INT, Company_name TEXT,
				Position TEXT, Job_skills TEXT, Job_start TEXT, Job_end TEXT, Skills TEXT)"
			
		rescue Exception => e
			puts 'Exception occured'
			puts e
		ensure
			db.close if db
		end
	end
end
=begin
#fail login
class Current_user
	def initialize
		begin
			db = SQLite3::Database.open 'resume_builder.db'
			db.execute "DROP TABLE IF EXISTS Current_User"
			db.execute "CREATE TABLE IF NOT EXISTS Current_User(id INTEGER PRIMARY KEY, User TEXT)"
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
=end



# sign up for new accont page
get '/sign_up' do
	return erb :sign_up
end

post '/sign_up' do
	#puts params[:user]
	
	#instantiance a new user
	User.new #params[:user]
	sign_up = params[:sign_up]
	email = sign_up['email_address']
	password = sign_up['password']
	
	begin
		db = SQLite3::Database.open "resume_builder.db"
		sql_command = "SELECT COUNT(Email) FROM Users WHERE Email = '#{email}'"
		sql_result = db.execute sql_command
		if email.empty? or password.empty?
			redirect to ('sign_up?empty_signup_field=Email address or password can not be empty.')
		end

		if sql_result[0][0] >= 1
			redirect to ('/sign_up?signup_error=Email address has already been taken. Try again.')
		end
		stm = db.prepare "INSERT INTO Users(Email, Password) VALUES(?, ?)"
		stm.bind_params email, password
		stm.execute
	rescue Exception => e
		puts "Exception occured"
		puts e
	ensure
		stm.close if stm
		db.close if db
	end
	redirect to("/")
end

# sign in page
get '/sign_in' do
	return erb :sign_in
end


# sign in action
post '/sign_in' do
	login = params[:login]
	email = login['email_address']
	password = login['password']
	begin
		db = SQLite3::Database.open "resume_builder.db"
		sql_command = "SELECT COUNT(Email) FROM Users WHERE Email = '#{email}' AND Password = '#{password}'"
		sql_result = db.execute sql_command
		if sql_result[0][0] >= 1
			#user = Current_user.new()
			#user.setUser = email
			#@x = user.getUser()
			#insert_current_user = db.prepare "INSERT INTO Current_User(User) VALUES(?)"
			#insert_current_user.bind_params @x
			#insert_current_user.execute
			session['user'] = login['email_address']
			redirect to ('/?login_id='+ session['user'])
		else
			#x = db.execute "SELECT User FROM Current_User"
			#puts x
			redirect to ('/sign_in?login_error=Your email address or password is incorrect.')
		end
	rescue Exception => e
		puts e
	ensure
		#insert_current_user.close if insert_current_user
		db.close if db
	end

	redirect to ('/')
	# add comment
=begin @user = User.first(:email_address => login['email_address'])
	@user_count = User.count(:email_address => login['email_address'] )
	

	if @user_count == 0
		redirect to('/sign_in?wrong=true')
	end


	user_email = @user.email_address
	user_password = @user.password
	

	if @user_count == 1 && user_password == login['password']
		redirect to('/')
	else
		redirect to('/sign_in?wrong=true')
	end	
=end
end

# log out page / action
get '/logout' do
=begin
	begin
	db = SQLite3::Database.open 'resume_builder.db'
	db.execute "DELETE FROM Current_User WHERE id = 1"
	rescue Exception => e
		puts "Exception occured"
		puts e
	ensure
	db.close if db
	end
=end
	session.clear
	redirect "/"
end


get '/' do
	return erb :index
end

# My resume
get '/resume' do
	return erb :resume	
end


get '/webpage' do
	return erb :webpage
end

# The fill out form to create resume
get '/resume_builder' do
	if session['user'].nil?
		#@need_login = 'Must sign in to access Resume Builder.'

		redirect to ('/?need_login=Must sign in to access Resume Builder!')
	end
	return erb :resume_form
end


# Outputs the inputs from resume_builder
post '/create_resume' do
	#if session['user'] == NIL
	#	redirect to ('/resume_builder?need_login=Need to login to save your resume!')
	#end
	@resume = params[:resume]
	Resume.new
	user = session['user']
	first_name = @resume['first_name']
	last_name = @resume['last_name'] 
	email_address = @resume['email_address']
	home_address = @resume['home_address']
	city = @resume['city']
	state = @resume['state']
	zip_code = @resume['zip_code']
	telephone_number = @resume['telephone_number']
	school = @resume['school']
	school_city = @resume['school_city']
	school_state = @resume['school_state']
	degree = @resume['degree']
	graduation_date = @resume['graduation_date']
	major = @resume['major']
	gpa = @resume['gpa']
	company_name = @resume['company_name']
	position = @resume['position'] 
	job_skills = @resume['job_skills']
	job_start = @resume['job_start']
	job_end = @resume['job_end'] 
	skills = @resume['skills']

	begin
		db = SQLite3::Database.open "resume_builder.db"
		
		stm = db.prepare "INSERT INTO Resume(User, Title, First_name, Last_name, Email, Home_address, City, State, 
				Zip_code, Telephone_number, School, School_city, School_state, Degree, Graduation_date, Major, 
				GPA, Company_name, Position, Job_skills, Job_start, Job_end, Skills)
				VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
		stm.bind_params session['user'], @resume['title'], first_name, last_name, email_address, home_address, city, state, zip_code, 
				telephone_number, school, school_city, school_state, degree, graduation_date, major, gpa, 
				company_name, position, job_skills, job_start, job_end, skills
		stm.execute
	rescue Exception => e
		puts 'Exception occured'
		puts e
	ensure
		stm.close if stm
		db.close if db
	end

	return erb :resume_output
end

get '/resumes/:id' do
	begin
		db = SQLite3::Database.open 'resume_builder.db'
		@resumes = db.execute "SELECT Resume.* FROM Resume WHERE Resume.id = '#{params[:id]}'"
	rescue Exception => e
		puts "Exception occured"
		puts e
	ensure
		db.close if db
	end
	@resume = @resumes[0]
	return erb :my_resume
end

delete '/resumes/:id' do
	begin
		db = SQLite3::Database.open 'resume_builder.db'
		@delete_resume = db.execute "DELETE FROM Resume WHERE Resume.id ='#{params[:id]}'" 
	rescue Exception => e
		puts 'Exception occured'
		puts e
	ensure
		db.close if db
	end
	redirect to ('/my_resumes')
end



get '/my_resumes' do
	begin
		db = SQLite3::Database.open 'resume_builder.db'
		@resumes = db.execute "SELECT id, Title FROM Resume WHERE Resume.User = '#{session['user']}'"
	rescue Exception => e
		puts "Exception occured"
		puts e
	ensure
		db.close if db
	end
	return erb :my_resumes
end

not_found do
	halt 404, 'Page not found'
end
