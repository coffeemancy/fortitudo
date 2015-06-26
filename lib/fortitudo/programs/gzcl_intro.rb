# encoding: utf-8
require_relative '../programs.rb'

module Fortitudo
  module Programs
    module GZCLIntro
      include Programs

      module_function

      def exerproc(pr)
        Programs.exerproc(pr)
      end

      def intensityproc(pr)
        Programs.intensityproc(Rational(8, 10))[pr]
      end

      def intensity(pr, exrx)
        srladder = [[[3, 3, 3, 1], 3], [[0, 0, 0, 2], 2], [[0, 0, 0, 3], 1]]
        Programs.
          intensity_weeks(exerproc(pr), intensityproc(pr))[srladder][exrx]
      end

      def squat(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns  = intensity(pr, primary[:squat])

        lunges = exp[assistance[:squat][0], 4, 5]
        asst   = ->(w) { [:T2, [lunges[w]]] }

        pushup = exp[assistance[:push][0],  5, 10]
        quads  = exp[accessory[:quads][0],  3, 10]
        vpull  = exp[assistance[:vpull][0], [2, 3, 4, 3], '1-2',
                     ->(e, w) { pr[e, 1] }]
        accs   = ->(w) { [:T3, [pushup[w], quads[w], vpull[w]]] }

        4.times.map { |w| intns[w] + asst[w] + accs[w] }
      end

      def bench(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns   = intensity(pr, primary[:bench])

        press   = exp[assistance[:press][0],  4, 5]
        asst    = ->(w) { [:T2, [press[w]]] }

        biceps  = exp[accessory[:biceps][0],  4, 12]
        rdelts  = exp[accessory[:rdelts][0],  2, '15-30']
        row     = exp[assistance[:row][0],    3, '10ea']
        triceps = exp[accessory[:triceps][0], 4, '15-30']
        accs    = proc do |w|
          [:T3, [row[w], triceps[w]], :T3, [biceps[w], rdelts[w]]]
        end

        4.times.map { |w| intns[w] + asst[w] + accs[w] }
      end

      def deadlift(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns   = intensity(pr, primary[:deadlift])

        fsquat  = exp[assistance[:squat][1], 4, 5, ->(e, w) { pr[e, 5 * w ] }]
        asst    = ->(w) { [:T2, [fsquat[w]]] }

        pushup  = exp[assistance[:push][0], 5, 10]
        hams    = exp[accessory[:hams][0],  3, '10ea']
        vpull   = exp[assistance[:vpull][1], ->(w) { 2 + w }, '2-4']
        accs    = ->(w) { [:T3, [pushup[w], hams[w], vpull[w]]] }

        4.times.map { |w| intns[w] + asst[w] + accs[w] }
      end
    end
  end
end
