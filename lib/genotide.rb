$:.push File.expand_path("../.", __FILE__)


require 'rubygems'
require 'active_support/all'
require 'pp'
require 'pry'
require "genotide/version"
require "genotide/generator"
require "genotide/dimensions/broadcast"

# binding.pry
# module Genotide
#   # Your code goes here...
# end

# btd = Genotide::BroadcastTimeDimension.generate
# binding.pry