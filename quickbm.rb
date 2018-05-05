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
      redirect "http://example.com"
    end
  end
end

get '/' do
  if !cookies[:name]
    redirect "/login.html"
  end
  # リスト表示
  cookies[:name]
end
