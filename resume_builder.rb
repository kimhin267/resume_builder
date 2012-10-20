require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'



# sign in page
get '/sign_in' do
	return erb :sign_in
end

# sign in action
post '/sign_in' do	

end

def authenticate_user
	# check user exists
	# check is user's password is correct
end

# sign up for new accont page
get '/sign_up' do 
	return erb :sign_up
end

post '/sign_up' do
end

# log out page / action
get '/logout' do

end



get '/' do
return erb :index
end

get '/resume' do
	return erb :resume	
end

get '/webpage' do
	return erb :webpage
end
# this will be the form
get '/resume_builder' do
	return erb :resume_form
end

post '/create_resume' do
	@resume = params[:resume]	
	return erb :resume_output
end

