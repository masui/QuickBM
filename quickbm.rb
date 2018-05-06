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

def username
  @username + "\t" + @password
end

def getcookie
  @username = cookies[:username].to_s
  @password = cookies[:password].to_s
  redirect "/_login" if @username == ''
end

get '/_login' do
  erb :login
end

post '/_register' do
  getcookie
  shortname = params['shortname']
  $bmdb.delete_many({username: username, shortname: shortname})
  d = {
    username: username,
    shortname: shortname,
    longname: params['longname'],
    description: params['description']
  }
  $bmdb.insert_one(d)
  redirect '/'
end

get '/_edit' do
  getcookie
  @description = params['description']
  @longname = params['longname']
  erb :edit
end

get '/:name!' do |shortname|
  getcookie
  data = $bmdb.find({username: username, shortname: shortname}).limit(1).first
  if data
    @shortname = shortname
    @description = data['description']
    @longname = data['longname']
  end
  erb :edit
end

get '/:name' do |shortname|
  getcookie

  data = $bmdb.find({username: username, shortname: shortname}).limit(1).first

  if request.env['HTTP_REFERER'] =~ /QuickBM\.com/i
    if data
      @shortname = shortname
      @description = data['description']
      @longname = data['longname']
    end
    erb :edit
  else
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
  redirect '/_login' if @username == ''
  cookies[:username] = @username
  cookies[:password] = @password
  redirect '/'
end

get '/' do
  getcookie
  # リスト表示
  @data = $bmdb.find({username: username})
  erb :list
end
