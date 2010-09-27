require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'json'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'multitrack'

require File.expand_path('../config/security.rb', __FILE__)

use Rack::ContentLength

map '/track.js' do
  run Multitrack::TrackApp.new
end

map '/record.gif' do
  run Multitrack::StatsApp.new
end

map '/exports/' do
  use SecurityMiddleware
  run Multitrack::ExportApp.new
end

map '/' do
  run lambda { |_| Multitrack::NotFound }
end
