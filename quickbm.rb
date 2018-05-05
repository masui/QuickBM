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

get '/:name' do
  if !cookies[:name]
    redirect "/login.html"
  end
  # どこかに飛ぶ
end

get '/' do
  if !cookies[:name]
    redirect "/login.html"
  end
  # リスト表示
  cookies[:name]
end
