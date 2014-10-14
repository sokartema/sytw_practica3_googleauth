require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'pry'
require 'orchestrate'

require 'erubis'
require 'pp'

set :erb, :escape_html => true

use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier'], config['secret']
end

enable :sessions
set :session_secret, '*&(^#234a)'

get '/' do
  erb :index
end

get '/auth/:name/callback' do
  config = YAML.load_file 'config/config.yml'
  client = Orchestrate::Client.new(config['orchestrate'])
  puts "Ping orchestrate: #{client.ping()}"
  @auth = request.env['omniauth.auth']
  puts "params = #{params}"
  puts "@auth.class = #{@auth.class}"
  puts "@auth info = #{@auth['info']}"
  puts "@auth info class = #{@auth['info'].class}"
  puts "@auth info name = #{@auth['info'].name}"
  puts "@auth info email = #{@auth['info'].email}"
  puts "@auth credentials = #{@auth['credentials']}"
  nombre = @auth['info'].name
  nombre.gsub!(/\s+/, "")
  hash = {:info => @auth['info']}
  hash[:credentials] = @auth['credentials']
  client.put(:items , nombre , hash)
  redirect "/orchestrate/#{nombre}"

end

get '/orchestrate/:name' do

  config = YAML.load_file 'config/config.yml'
  client = Orchestrate::Client.new(config['orchestrate'])
  @r = client.get(:items,params[:name])
  puts @r.body
  erb :orchestrate

end
