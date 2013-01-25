require 'sinatra'
require 'sqlite3'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'data_mapper'
require 'digest'
require 'pdfkit'
require 'pony'

use PDFKit::Middleware
enable :sessions


DataMapper.setup :default, "sqlite://#{Dir.pwd}/resume_builder.db"
#If there is a error while saving, error.
#DataMapper::Model.raise_on_save_failure = true 


class User
	include DataMapper::Resource
	property :id 				, Serial
	property :email_address		, String, :format => :email_address
	property :password			, String#, :length => 8..20
	validates_uniqueness_of :email_address

	has n, :resumes
end


class Resume
	include DataMapper::Resource
	property :id 				, Serial
	property :title				, String, :length => 0..35, :message => "The resume title is too long, there is a maximum character length of 35"
	property :first_name        , String, :required => true
	property :last_name         , String, :required => true
	property :email_address     , String, :required => true, :format => :email_address,
										  :messages => {:format => "Please enter a valid email address",
										 				:presence => "Email address must not be blank"}
	property :home_address 		, String, :required => true
	property :city              , String, :required => true
	property :state             , String, :required => true
	property :zip_code          , Integer, :required => true
	property :telephone_number  , Integer, :required => true

	has n, :educations, :constraint => :destroy
	has n, :jobs, :constraint => :destroy
	has n, :otherskills, :constraint => :destroy 
	belongs_to :user

	
end

class Education
	include DataMapper::Resource
	property :id 				, Serial
	property :school 			, String, :required => true
	property :school_city 		, String, :required => true
	property :school_state 		, String, :required => true
	property :degree 			, String, :required => true
	property :graduation_date 	, String, :required => true
	property :major 			, String, :required => true
	property :gpa 				, Integer, :required => true

	belongs_to :resume
	 

end

class Job
	include DataMapper::Resource
	property :id 				, Serial
	property :company_name 		, String, :required => true
	property :position 			, String, :required => true
	property :job_skills 		, String, :required => true, :length => 200, 
										  :messages => {:length => "The job description is too long, there is a maximum character length of 200.",
										 				:default => nil}
	property :job_start 		, String, :required => true
	property :job_end 			, String, :required => true
	

	belongs_to :resume	
end

class Otherskill
	include DataMapper::Resource
	property :id 				, Serial
	property :skills 			, String, :required => false

	belongs_to :resume
end

#DataMapper.finalize shiuld be decakred after declaring all models
#DataMapper.auto_upgrade! will detect changes in the model and update/add a new row to the table
DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
	return erb :index
end


get '/signin_page' do
	return erb :signin_page
end


post '/signin' do
	login = params[:login]
	email = login['email_address']
	password = Digest::SHA1.hexdigest login['password']
	user = User.first(:email_address => email)
	user_count = User.count(:email_address => login['email_address'] )

	if user_count === 0
		redirect to('/signin_page?email_do_not_exists=The email address you have enter does not exist.')
	end

	user_password = user.password
	

	if user_count === 1 && user_password === password
		session['user'] = email
		@user = email
		if params[:device] == 'mobile_app'
			redirect to('/mobile_app')
		else
			redirect to('/')
		end
	else
		redirect to('/signin_page?login_error=Your email address or password is incorrect.')
	end	
end

get '/mobile_app' do
	@user = User.first(:email_address => session['user'])
	@resumes = @user.resumes
	return erb :"mobile/mobile_app", {:layout => :"mobile/layout"}
end

get '/signup_page' do
	return erb :signup_page
end

get '/share_resume/:id' do
	@user = User.first(:email_address => session['user'])
	@resume = @user.resumes.first(params[:id])
	return erb :"mobile/share_resume"
end

post '/send_resume/:id' do 
	@user = User.first(:email_address => session['user'])
	@resume = @user.resumes.first(params[:id])
		Pony.mail({
			:via => :smtp,
		    :via_options => {
		   		:address => 'smtp.gmail.com',
		   		:port => 587,
		   		:user_name => 'kim.hin267@gmail.com',
		   		:password => 'KH1990@gm',
		   		:authentication => :plain,
		   		:enable_starttls_auto => true
		   	},
			:to => params[:other_contact],
		    :from => @user.email_address,
		    :subject => "Welcome to Breezy Resume!",
		    :html_body => erb(:email)
		})
	return erb :"mobile/share_resume"
end

post '/signup' do
	#instantiance a new user
	#This is the proper way of doing it.
	@user = User.new(params[:sign_up]) #set new parameters and do params[:user] to get input and then use the dot notation to save data into new user
	#Works but using User.new(params[]) is more efficient
	#sign_up = params[:sign_up]
	#@user.email_address = sign_up['email_address']
	@user_count = User.count(:email_address => @user.email_address)
	password = @user.password
	if password.length <= 7
		redirect ('/signup_page?password_error=Password must have 8 or more characters.')
	end
	@hash_password = Digest::SHA1.hexdigest @user.password
	@user.password = @hash_password
	# puts @hash_password
	# puts @hash_password.length
	if (@user_count >= 1)
		puts "case a"
		redirect ('/signup_page?email_taken_error=Email address has already been taken.')
	end

	begin
		if @user.save
			session['user'] = @user.email_address
			Pony.mail :via => :smtp,
					   :smtp => {
					   		:host => 'smtp.gmail.com',
					   		:port => 465,
					   		:user => 'kim.hin267@gmail.com',
					   		:password => 'KH1990@gm',
					   		:auth => :plain,
					   		:domain => 'breezyresume.com',
					   		:enable_starttls_auto => true
					   	},
						:to => @user.email_address,
					  :from => "kim.hin267@gmail.com",
					  :subject => "Welcome to Breezy Resume!",
					  :body => erb(:email)
			redirect ('/')
		# elsif password.length <= 7
		# 	redirect ('/signup_page?password_error=Password must have 8 or more characters.')	
		else 
			@user.raise_on_save_failure
			redirect ('/signup_page?not_email=Please enter a valid email address.')
		end
	rescue Exception => e
		puts "Error #{e.inspect}" 	
	end
end



# user's resumes
get '/my_resumes' do
	if session['user'].nil?
		redirect to URI.parse(URI.encode('/signin_page?need_login=Must sign in to view resumes!'))
	end
	@user = User.first(:email_address => session['user'])
	@resumes = @user.resumes
	#puts @resumes.length
	#@resumes.each do |i|
	#	puts i.title
	#end

	return erb :my_resumes
end

get '/view_resumes/:id' do
	@user = User.first(:email_address => session['user'])
	@resumes = @user.resumes.first(params[:id])
	#puts @school
	return erb :my_resume
end


delete '/view_resumes/:id' do
	@user = User.first(:email_address => session['user'])
	@resumes = @user.resumes.first(params[:id]).destroy
	#puts @resumes
	redirect to ('/my_resumes')
end

get '/resume_pdf/:id' do
	@user = User.first(:email_address => session['user'])
	@resumes = @user.resumes.first(params[:id])
	return erb :resume_pdf
end

get '/logout' do
	session.clear
	redirect "/"
end


get '/create_resume' do
	if session['user'].nil?
		redirect to URI.parse(URI.encode('/signin_page?need_login=Must sign in to access Resume Builder!'))
	end
	session[:errors] = []
	session[:errors].clear
	return erb :resume_form
end


# Outputs the inputs from resume_builder
post '/create_resume' do
	#DataMapper::Model.raise_on_save_failure = true
	# session[:resume_output] = []
	session[:errors].clear
	@user = User.first(:email_address => session['user'])
	@resume = @user.resumes.new(params[:resume])
	@resume.save
	@resume.errors.each do |error|
 		error.each do |e|
 			if e == "Resume must not be blank"
 			elsif e === "Zip code must be an integer"
				session[:errors] << "Please enter a valid zip code"
			elsif e === "Telephone number must be an integer"
				session[:errors] << "Please make sure that telephone number does not have any hyphens or spaces"		
 			else
				session[:errors] << e
			end
		end
	end

	params[:education].each_key do |school|
		@school = @resume.educations.new(params[:education][school])
		if @school.save
		else
			@school.errors.each do |error|
	 			error.each do |e|
	 				if e == "Resume must not be blank"
	 				elsif e === "Gpa must be an integer"	
		 			else
						session[:errors] << e
					end
	 			end 
	 		end
		end
	end
	puts @school.save
	puts @school.errors.inspect
	params[:job].each_key do |job|
		@job = @resume.jobs.new(params[:job][job])
		if @job.save
			else
			@job.errors.each do |error|
	 			error.each do |e|
	 				if e == "Resume must not be blank"
		 			else
						session[:errors] << e
					end
	 			end 
	 		end
		end
	end
	
	if session[:errors].empty? === false
		erb :resume_form
	else
		# session[:resume_output].clear
		erb :resume_output 
	end
	# puts @job.errors.inspect
	# params[:otherskill].each_key do |other|
	# 	@otherskill = @resume.otherskills.new(params[:otherskill][other])
	# 	@otherskill.save
	# end

	# session[:resume_output] << @resume.title << @resume.first_name << @resume.last_name << 
	# @resume.email_address << @resume.home_address << @resume.city << 
	# @resume.state << @resume.zip_code << @resume.telephone_number

	# @resume.educations.each do |e|
	# 	session[:resume_output] << e.school << e.school_city << e.school_state << 
	# 	e.degree << e.graduation_date << e.major << e.gpa
	# end

	# @resume.jobs.each do |j|
	# 	session[:resume_output] << j.company_name << j.position << j.job_skills << 
	# 	j.job_start << j.job_end
	# end
	
	# @resume.otherskills.each do |o|
	# 	session[:resume_output] << o.skills
	# end

	#unless @resume.errors.nil? and @school.errors.nil? and @job.errors.nil? and @otherskill.errors.nil? 
end

get '/edit_resume/:id' do 
	@user = User.first(:email_address => session['user'])
	@resume = @user.resumes.first(params[:id])
	session[:errors] = []
	session[:errors].clear
	return erb :edit_resume
end

post '/update_resume/:id' do
	@user = User.first(:email_address => session['user'])
	@resume = @user.resumes.first(params[:id])
	@resume.save
	
	redirect ('/my_resumes')
end

get '/about' do
	return erb :about
end

# my personal resume
get '/resume' do
	return erb :resume	
end

not_found do
	halt 404, 'Page not found'
end



























=begin
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
#get '/sign_in' do
#	return erb :sign_in
#end

=begin
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
=begin@user = User.first(:email_address => login['email_address'])
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
end


# log out page / action


=begin
get '/' do
	return erb :index
end


=begin
# My resume
get '/resume' do
	return erb :resume	
end


get '/webpage' do
	return erb :webpage
end
=end

# The fill out form to create resume

=begin
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
=end

=begin
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
=end



#
#
#using sqlite Database
#
#

=begin
class User
	def initialize
		begin
			db = SQLite3::Database.open "resume_builder.db" || ENV['DATABASE_URL']
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
=end

=begin
post '/signup' do
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
			redirect to URI.parse(URI.encode('/signup_page?empty_signup_field=Email address or password can not be empty.'))
		end

		if sql_result[0][0] >= 1
			redirect to URI.parse(URI.encode('/signup_page?email_taken_error=Email address has already been taken. Try again.'))
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
end
=end

=begin
post '/signin' do
	login = params[:login]
	email = login['email_address']
	password = login['password']

	begin
		db = SQLite3::Database.open "resume_builder.db"
		sql_command = "SELECT COUNT(Email) FROM Users WHERE Email = '#{email}' AND Password = '#{password}'"
		sql_result = db.execute sql_command
		if sql_result[0][0] >= 1
			session['user'] = login['email_address']
			redirect to ('/')
		else
			redirect to URI.parse(URI.encode('/signin_page?login_error=Your email address or password is incorrect.'))
		end
	rescue Exception => e
		puts e
	ensure
		db.close if db
	end
end

get '/my_resumes' do
	if session['user'].nil?
		redirect to URI.parse(URI.encode('/signin_page?need_login=Must sign in to view resumes!'))
	end

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
=end
