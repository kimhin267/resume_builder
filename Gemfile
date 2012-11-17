source :rubygems
gem 'sinatra', '1.3.3'
gem 'thin'
gem 'sqlite3'
gem 'dm-core'
gem 'dm-sqlite-adapter'
gem 'dm-migrations'
gem 'dm-validations'
gem 'dm-timestamps'

group :production, :staging do
  gem "pg"
end

group :development, :test do
  gem "sqlite3-ruby", "~> 1.3.0", :require => "sqlite3"
end