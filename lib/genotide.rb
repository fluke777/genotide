$:.push File.expand_path("../.", __FILE__)


require 'rubygems'
require 'active_support/all'
require 'pp'
require 'pry'
require 'csv'
require 'benchmark'
require "genotide/version"
require "genotide/generator"
require "genotide/dimensions/broadcast"

include Genotide::BroadcastTimeDimension
btd = Genotide::BroadcastTimeDimension.generate(Date.new(1900,12,31), Date.new(2050,12,25), :first_day_of_week => "Mon")
btd.save(:file_prefix => "broadcast")