require 'rubygems'
begin
  require 'moneta'
rescue LoadError
  puts "You need the moneta gem to use ActiveKV"
  exit
end
begin
  require 'active_support'
rescue LoadError
  puts "You need the ActiveSupport gem to use ActiveKV"
  exit
end
require 'activekv/base'
