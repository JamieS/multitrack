# Here you can configure a middleware 
# to do basic user authentication for you
# You can replace it with a noop, use http basic auth
# or replace it with a more compex middleware that allows
# you to authenticate with google apps accounts, open id or CAS.
#
# Check out the warden project for some inspiration
#
#


if ENV['HTTP_USERNAME'] && ENV['HTTP_PASSWORD']

  class SecurityMiddleware < Struct.new(:app)
    def call(env)
      Rack::Auth::Basic.new(app, 'Multitrack') do |username, password|
        [username, password] == [ENV['HTTP_USERNAME'], ENV['HTTP_PASSWORD']]
      end.call(env)
    end
  end

else
  
  class SecurityMiddleware < Struct.new(:app)
    def call(env)
      [403, {'Content-Type' => 'text/plain'}, ['Configure security settings in config/security.rb']] 
    end
  end

end


