require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'json'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'multitrack'

use Rack::ContentLength

map '/track.js' do
  run Multitrack::TrackApp.new
end

map '/record.gif' do
  run Multitrack::StatsApp.new
end

map '/' do
  run Multitrack::NotFound
end
