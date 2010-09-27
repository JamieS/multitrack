require 'multitrack/database'

module Multitrack
  class Visit < ActiveRecord::Base
    def to_csv
      "#{id}, #{uid}, #{landing_page.gsub(',','\\,')}, #{referrer.gsub(',','\\,')}, #{created_at.to_s(:db)}\n"
    end
    validates_presence_of :uid
  end

  NotFound = [404, {'Content-Type' => 'text/plain'}, ['Not Found']]

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

  class ExportApp
    
    def call(env)
      request = Rack::Request.new(env)
      query   = Multitrack::Visit.order("id").limit(1000)

      if request.params['page']
        query = query.offset(1000 * Integer(request.params['page']) - 1)
      end

      if request.params['since']
        query = query.where("id > ?", request.params['since'])
      end

      File.extname(request.path_info)

      case File.extname(request.path_info)  
      when '', '.csv'
        [200, {'Content-Type' => 'text/csv'}, [query.all.collect(&:to_csv).join]]
      when '.json'
        [200, {'Content-Type' => 'application/json'}, [query.all.to_json]]
      when '.xml'
        [200, {'Content-Type' => 'application/xml'}, [query.all.to_xml]]
      else
        return NotFound
      end
       
    end

  end
end
