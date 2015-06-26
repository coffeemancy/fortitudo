#!/usr/bin/env ruby
# encoding: UTF-8

require 'edn'
require 'English'
require 'erubis'
require_relative '../lib/fortitudo.rb'
require_relative '../lib/fortitudo/programs.rb'
require 'optparse'

if __FILE__ == $PROGRAM_NAME
  extend Fortitudo

  opt_parser(options = { :template => 'default.tex.erb' }).parse!

  # read edn
  binds = read_exercises(options[:config])

  # defaults to GZCL Regular
  binds[:program_name] ||= 'GZCL Regular'
  binds[:program_module] =
    case binds.fetch(:program_module, nil)
    when 'GZCLBigOnBasicsIntro' then Fortitudo::Programs::GZCLBigOnBasicsIntro
    when 'GZCLBigOnBasics'      then Fortitudo::Programs::GZCLBigOnBasics
    when 'GZCLIntro'            then Fortitudo::Programs::GZCLIntro
    when 'GZCLIntroPlus'        then Fortitudo::Programs::GZCLIntroPlus
    else Fortitudo::Programs::GZCLRegular
    end


  eruby = Erubis::Eruby.new(::File.read(options[:template]))
  puts eruby.result(binds)
end
