# -*- coding: utf-8 -*-
# -*- ruby -*-

$:.unshift File.expand_path 'lib', File.dirname(__FILE__)

# 標準ライブラリ
require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/cross_origin'
require 'mongo'
require 'json'

enable :cross_origin # Chrome拡張機能から読めるようにするため

$episodb = Mongo::Client.new(ENV['MONGODB_URI'])[:quickbm]

configure do
  set :root, File.dirname(__FILE__)
  set :public_folder, settings.root + '/public'
end

get '/login' do
  erb :login
end

post '/logined' do
  cookies[:name] = params['id']
  redirect '/'
end

post '/register' do
  username = cookies[:name]
  if !username
    redirect "/login"
  end
  d = {
    user: username,
    name: params['shortname'],
    longname: params['longname']
  }
  $episodb.insert_one(d)
  redirect '/'
end

get '/:name!' do |shortname|
  @username = cookies[:name]
  if !@username
    redirect "/login"
  else
    @shortname = shortname
    erb :edit
  end
end

get '/:name' do |shortname|
  username = cookies[:name]
  if !username
    redirect "/login"
  else
    # どこかに飛ぶ
    data = $episodb.find({user: username, name: shortname}).limit(1).first
    if data then
      redirect data['longname']
    else
      redirect "https://www.google.com/search?q=#{shortname}"
    end
  end
end

get '/' do
  username = cookies[:name]
  if !username
    redirect "/login"
  else
    #$episodb.delete_many({user: username, name: 'test'})
    #d = { user: username, name: 'test', longname: 'http://pitecan.com' }
    #$episodb.insert_one(d)
    @data = $episodb.find({user: username})
    erb :list
  end
  # リスト表示
  #cookies[:name]
end
