require 'sinatra'
require 'warden'

class resume_builder < Sinatra::Application
	use Rack::Session::Cookie

	use Warden::Manager do |manager|
		manager.default_strategies :password
		manager.failure_app = resume_builder
		manager.serialize_into_session {|user| user.id}
		manager.serialize_from_session {|id| Datastore.for(:user).find_by_id(id)}
	end

	Warden::Manager.before_failure do |env,opts|
  		env['REQUEST_METHOD'] = 'POST'
	end

	Warden::Strategies.add(:password) do
  		def valid?
    		params["email"] || params["password"]
  		end

  		def authenticate!
    		user = Datastore.for(:user).find_by_email(params["email"])
    		if user && user.authenticate(params["password"])
      			success!(user)
    		else
      			fail!("Could not log in")
    		end
  		end
	end
	
	def warden_handler
    	env['warden']
	end

	def current_user
    	warden_handler.user
	end

	def check_authentication
    	redirect '/login' unless warden_handler.authenticated?
	end

	get "/login" do
    	erb '/login'.to_sym
  	end

  	post "/session" do
    	warden_handler.authenticate!
    	if warden_handler.authenticated?
      		redirect "/users/#{warden_handler.user.id}" 
    	else
      		redirect "/"
    	end
  	end

  	get "/logout" do
    	warden_handler.logout
    	redirect '/login'
  	end

  	post "/unauthenticated" do
    	redirect "/"
  	end

  	get "/protected_page" do
    	check_authentication
    	erb 'admin_only_page'.to_sym
	end


	get '/' do
	return erb :index.to_sym
	end

	get '/resume' do
		return erb :resume.to_sym	
	end

	get '//protected_page' do
		return erb :webpage.admin_only_page
	end
	# this will be the form
	get '/resume_builder' do
		return erb :resume_form.to_sym
	end

	post '/create_resume' do
		@resume = params[:resume]	
		return erb :resume_output.to_sym
	end
end
