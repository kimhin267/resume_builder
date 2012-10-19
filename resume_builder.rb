require 'sinatra'

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

