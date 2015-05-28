#!/usr/bin/env ruby
# encoding: UTF-8

require 'edn'
require 'English'
require 'optparse'

# Strength-Training Erubis/LaTeX Spreadsheet Warrior Tool
module Fortitudo
  module_function

  def each_work(work, exrx = nil, &block)
    oldtier, = nil
    oldexrx = exrx
    work.each_slice(2).each_with_index do |(tier, assts), no|
      asst    = assts.first.first
      newtier = tier != oldtier
      newexrx = asst != oldexrx
      block[tier, assts, no, newtier, newexrx]
      oldtier = tier
      oldexrx = asst
    end
  end

  def nearest(num, val = 5)
    num.fdiv(val).round * val
  end

  def prproc(exercises, bands)
    proc do |x, delta = 0|
      ex = exercises[x]
      case ex
      when Array # each
        ld, mod = ex
        [ld + delta, mod].join('')
      when Symbol # bands
        bands[[[bands.find_index(ex) + delta, bands.count - 1].min, 0].max].to_s
      when Numeric # straight load
        ex + delta
      else # shouldn't get here, can't delta it
        ex
      end
    end
  end

  def opt_parser(options)
    OptionParser.new do |opts|
      opts.banner = 'Usage: fortitudo.rb [options]'

      opts.on('-cCFG',
              '--config=CFG',
              'Exercise config file to use (edn)') do |cfg|
        options[:config] = cfg
      end

      opts.on('-tTEMPLATE',
              '--tempalte=TEMPLATE',
              'Erubis template to use (erb)') do |template|
        options[:template] = template
      end
    end
  end

  def read_exercises(edn_file)
    EDN.read(::File.read(edn_file))
  end

  def setrepload
    proc do |sets, reps, ld, units|
      sr = [sets, reps, ld]
      units ||= '\#' if ld.is_a?(Numeric)
      '  & ' + sr.join('$\times$') + units.to_s + '\tabularnewline'
    end
  end

  # counts number of items in tier in enum
  def tiercount(tier, enum)
    enum.select { |(tr, _)| tr == tier }.flat_map { |_, vs| vs }.count
  end
end

if __FILE__ == $PROGRAM_NAME
  require './programs.rb'
  extend Fortitudo

  opt_parser(options = { :template => 'default.tex.erb' }).parse!

  # read edn
  binds = read_exercises(options[:config])

  # defaults to GZCL Regular
  binds[:program_name] ||= 'GZCL Regular'
  binds[:program_module] =
    case binds.fetch(:program_module, nil)
    when 'GZCLIntro'     then Fortitudo::Programs::GZCLIntro
    when 'GZCLIntroPlus' then Fortitudo::Programs::GZCLIntroPlus
    else Fortitudo::Programs::GZCLRegular
    end

  require 'erubis'

  eruby = Erubis::Eruby.new(::File.read(options[:template]))
  puts eruby.result(binds)
end
