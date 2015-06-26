# encoding: utf-8
require_relative '../fortitudo.rb'

module Fortitudo
  module Programs
    extend Fortitudo

    module_function

    def bands
      [:R, :B, :G]
    end

    def exerproc(pr)
      nsorindex = proc do |item, wk|
        case item
        when Numeric, String then item
        else item[wk]
        end
      end

      # builds up a proc which takes a week, using pr proc
      proc do |ex, sets, reps, ld = nil|
        # returns a proc which takes a week and returns
        # the [exercise, [sets, reps, load]]
        proc do |wk|
          exc = ex.is_a?(String) ? ex : ex[wk]
          sts = nsorindex[sets, wk]
          rps = nsorindex[reps, wk]
          lod = ld.nil? ? pr[exc] : ld[exc, wk]
          sts.is_a?(Numeric) && sts.zero? ? nil : [exc, [sts, rps, lod]]
        end
      end
    end

    def intensityproc(start, inc = Rational(25, 1000), nearest_val = 5)
      # takes a pr proc
      proc do |pr|
        # takes a 'n' as 'nth exercise in ladder'
        proc do |n|
          # returns proc taking exercise and week, e.g. for exerproc
          ->(e, w) { nearest(pr[e] * (start + (w + n) * inc), nearest_val) }
        end
      end
    end

    def intensity_weeks(exp, inp)
      proc do |srladder|
        proc do |exrx|
          # progress set-rep ladder
          ladr = srladder.reduce([[], 0]) do |(arr, index), (sets, reps)|
            [arr + [exp[exrx, sets, reps, inp[index]]], index+1]
          end.first
          proc do |w|
            3.times.reduce([]) do |a, e|
              ex = ladr[e][w]
              ex.nil? ? a :a + [:T1, [ex]]
            end
          end
        end
      end
    end

    def volume_weeks(exp, pr, nearest_val = 5)
      proc do |sets, reps, percs, tiers|
        proc do |exrx|
          vol = exp[exrx, sets, reps,
                    proc do |e, w|
                      nearest(pr[e] * Rational(percs[w], 100), nearest_val)
                    end]
          proc do |w|
            if sets[w].respond_to?(:zero?)
              sets[w].zero? ? [] : [tiers[w], [vol[w]]]
            else
              [tiers[w], [vol[w]]]
            end
          end
        end
      end
    end
  end
end

require_relative './programs/gzcl_intro.rb'
require_relative './programs/gzcl_intro_plus.rb'
require_relative './programs/gzcl_regular.rb'
require_relative './programs/gzcl_regular_plus.rb'
require_relative './programs/gzcl_big_on_basics_intro.rb'
require_relative './programs/gzcl_big_on_basics.rb'
