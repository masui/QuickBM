# -*- coding: utf-8 -*-
# -*- ruby -*-

$:.unshift File.expand_path 'lib', File.dirname(__FILE__)

# 標準ライブラリ
require 'sinatra'
require 'sinatra/cookies'
require 'mongo'

$bmdb = Mongo::Client.new(ENV['MONGODB_URI'])[:quickbm]

configure do
  set :root, File.dirname(__FILE__)
  set :public_folder, settings.root + '/public'
end

get '/login' do
  erb :login
end

post '/register' do
  username = cookies[:name]
  name = params['shortname']
  if !username
    redirect "/login"
  end
  $bmdb.delete_many({user: username, name: name})
  d = {
    user: username,
    name: name,
    longname: params['longname'],
    description: params['description']
  }
  $bmdb.insert_one(d)
  redirect '/'
end

get '/:name!' do |shortname|
  @username = cookies[:name]
  if !@username
    redirect "/login"
  else
    data = $bmdb.find({user: @username, name: shortname}).limit(1).first
    @shortname = shortname
    @description = data['description']
    @longname = data['longname']
    erb :edit
  end
end

get '/:name' do |shortname|
  username = cookies[:name]
  if !username
    redirect "/login"
  else
    # 登録アドレスに飛ぶ
    data = $bmdb.find({user: username, name: shortname}).limit(1).first
    if data then
      redirect data['longname']
    else
      redirect "https://www.google.com/search?q=#{shortname}"
    end
  end
end

post '/' do # ログインフォームから
  username = params['username']
  redirect '/login' unless username
  cookies[:name] = username
  redirect '/'
end

get '/' do
  username = cookies[:name]
  if !username
    redirect "/login"
  else
    # リスト表示
    @data = $bmdb.find({user: username})
    erb :list
  end
end
