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
  @username = cookies[:username].to_s
  @password = cookies[:password].to_s
  shortname = params['shortname']
  if @username == ''
    redirect "/login"
  end
  $bmdb.delete_many({username: @username + "\t" + @password, shortname: shortname})
  d = {
    username: @username + "\t" + @password,
    shortname: shortname,
    longname: params['longname'],
    description: params['description']
  }
  $bmdb.insert_one(d)
  redirect '/'
end

get '/:name!' do |shortname|
  @username = cookies[:username].to_s
  @password = cookies[:password].to_s
  if @username == ''
    redirect "/login"
  else
    data = $bmdb.find({username: @username + "\t" + @password, shortname: shortname}).limit(1).first
    if data
      @shortname = shortname
      @description = data['description']
      @longname = data['longname']
    end
    erb :edit
  end
end

get '/:name' do |shortname|
  @username = cookies[:username].to_s
  @password = cookies[:password].to_s
  @shortname = shortname
  if @username == ''
    redirect "/login"
  else
    # 登録アドレスに飛ぶ
    data = $bmdb.find({username: @username + "\t" + @password, shortname: shortname}).limit(1).first
    if data then
      redirect data['longname']
    else
      redirect "https://www.google.com/search?q=#{shortname}"
    end
  end
end

post '/' do # ログインフォームから
  @username = params['username'].to_s
  @password = params['password'].to_s
  redirect '/login' if @username == ''
  cookies[:username] = @username
  cookies[:password] = @password
  redirect '/'
end

get '/' do
  @username = cookies[:username].to_s
  @password = cookies[:password].to_s
  puts "username = #{@username}"
  puts "password = #{@password}"
  if @username == ''
    redirect "/login"
  else
    # リスト表示
    @data = $bmdb.find({username: @username + "\t" + @password})
    erb :list
  end
end
