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

# get '/set' do
#   cookies[:test] = 'foobar'
#   "Hello"
# end
# 
# get '/get' do
#   cookies[:test]
# end

get '/login' do
  erb :login
end

get '/:name!' do |shortname|
  username = cookies[:name]
  if !username
    cookies[:name] = "masui"
    redirect "/login.html"
  else
    erb :edit
  end
end

get '/:name' do |shortname|
  username = cookies[:name]
  if !username
    cookies[:name] = "masui"
    redirect "/login.html"
  else
    # どこかに飛ぶ
    d = $episodb.find({user: username, name: shortname}).limit(1).first
    if d then
      redirect d['longname']
    else
      redirect "https://www.google.com/search?q=#{shortname}"
    end
  end
end

get '/' do
  username = cookies[:name]
  if !username
    redirect "/login.html"
  else
    $episodb.delete_many({user: username, name: 'test'})
    d = { user: username, name: 'test', longname: 'http://pitecan.com' }
    $episodb.insert_one(d)
  end
  # リスト表示
  cookies[:name]
end
