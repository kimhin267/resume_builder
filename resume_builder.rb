require 'rubygems'
require 'sinatra'

get '/resume' do

	return erb :resume	
end

# this will be the form
get '/resume_builder' do
	return erb :resume_form
end


post '/create_resume' do
	@resume = params[:resume]
	
	return erb :resume_output
end

