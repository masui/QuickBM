require 'rubygems'
require 'sinatra'
  
require './quickbm.rb'

Encoding.default_external = 'utf-8'

run Sinatra::Application
