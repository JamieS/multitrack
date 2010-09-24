require 'multitrack/database'

module Multitrack
  class Visit < ActiveRecord::Base
    validates_presence_of :uid
  end

  not_found = [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
  NotFound = lambda { |env| not_found }

  class StatsApp
    GifImage = [
      200,
      { 'Content-Type' => 'image/gif',
        'Cache-Control' => 'private, must-revalidate' },
      ["GIF89a\001\000\001\000\200\000\000\000\000\000\000\000\000!\371\004\001\000\000\000\000,\000\000\000\000\001\000\001\000\000\002\002D\001\000;"]]

    def call(env)
      params = Rack::Request.new(env).params

      if params['a']
        Multitrack::Visit.create(
          :uid => params['a'],
          :referrer => params['r'],
          :landing_page => params['l'])
      end

      GifImage
    end
  end

  class TrackApp
    require 'erb'
    template_path = File.expand_path('../multitrack/templates/visit.js.erb', __FILE__)
    template = ERB.new(File.read(template_path))
    template.def_method(self, 'render(env)', template_path)

    Response = [
      200,
      { 'Content-Type' => 'text/javascript',
        'Cache-Control' => 'public, maxage=3600' }]

    def call(env)
      Response + [[render(env)]]
    end
  end
end
