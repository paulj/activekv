require 'rubygems'
begin
  require 'moneta'
  require 'moneta/memory'
rescue LoadError
  p "You need the moneta gem to use ActiveKV"
  exit
end
begin
  require 'active_support'
rescue LoadError
  p "You need the ActiveSupport gem to use ActiveKV"
  exit
end
require 'activekv/base'
