# encoding: utf-8
require_relative '../programs.rb'

module Fortitudo
  module Programs
    module GZCLIntroPlus
      include GZCLIntro

      module_function

      def intensityproc(pr)
        Programs.intensityproc(Rational(825, 1000))[pr]
      end

      def intensity(pr, exrx)
        srladder = [[[1, 1, 1, 2], 3], [[2, 2, 2, 3], 2], [[3, 3, 3, 5], 1]]
        Programs.
          intensity_weeks(exerproc(pr), intensityproc(pr))[srladder][exrx]
      end

      def bench_volume(pr, exrx)
        squat_volume(pr, exrx)
      end

      def deadlift_volume(pr, exrx)
        args = [[0, 0, 0, 10], [0, 0, 0, 2],
                [0, 0, 0, 85], [nil, nil, nil, :T1]]
        volume_weeks(pr)[args][exrx]
      end

      def squat_volume(pr, exrx)
        args = [[5, 3, 7, 10],    [7, 8, 3, 2],
                [55, 65, 75, 85], [:T2, :T2, :T2, :T1]]
        volume_weeks(pr)[args][exrx]
      end

      def volume_weeks(pr, nearest_val = 5)
        Programs.volume_weeks(exerproc(pr), pr, nearest_val)
      end

      def squat(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns  = intensity(pr, primary[:squat])
        vol    = squat_volume(pr, primary[:squat])

        lunges = exp[assistance[:squat][0], 3,
                     ->(w) { [8, 10, 10][w].to_s + 'ea' },
                     ->(e, w) { pr[e, 5 * w.div(2)] }]

        asst   = ->(w) { [:T2, [lunges[w]]] }

        glutes = exp[accessory[:glutes][0], 3, '12-15']
        vpull  = exp[assistance[:vpull][0], 3, '3-6', ->(e, w) { pr[e, 1] }]
        accs   = ->(w) { [:T3, [glutes[w], vpull[w]]] }

        4.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] }
      end

      def bench(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns   = intensity(pr, primary[:bench])
        vol     = bench_volume(pr, primary[:bench])

        press = exp[->(w) { assistance[:press][w % 2] },
                    [3, 3, 5], [8, 10, 5],
                    ->(e, w) { pr[e, 2 * w.div(2)] }]
        row   = exp[assistance[:row][0], [3, 3, 4], [8, 12, 10]]
        t3row = [:T3, [row[2]]]

        asst = 2.times.map { |w| [:T2, [press[w], row[w]]] }.
          push([:T2, [press[2]]] + t3row).push(t3row)

        biceps  = exp[accessory[:biceps][0],  4, 12]
        chest   = exp[accessory[:chest][0],   3, 12]
        rdelts  = exp[accessory[:rdelts][0],  3, '15-30']
        triceps = exp[accessory[:triceps][0], 4, '15-30']
        accs    = proc do |w|
          [:T3, [chest[w], rdelts[w]], :T3, [biceps[w], triceps[w]]]
        end

        4.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] }
      end

      def deadlift(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns   = intensity(pr, primary[:deadlift])
        vol     = deadlift_volume(pr, primary[:deadlift])

        fsquat = exp[assistance[:squat][1], 4, 5, ->(e, w) { pr[e, 5 * w ] }]
        pull   = exp[assistance[:pull],     3, [8, 10]]
        row    = exp[assistance[:row][1],   4, 6]
        asst   = proc do |w|
          (w < 3) ? [:T2, [fsquat[w]], :T2, [[pull, pull, row][w][w]]] : []
        end

        hams  = exp[accessory[:hams][0], 3,
                    ->(w) { [8, 10, 10, 12][w].to_s + 'ea' }]
        vpull = exp[assistance[:vpull][0], ->(w) { 3 + w }, '2-4']
        accs  = ->(w) { [:T3, [hams[w], vpull[w]]] }

        4.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] }
      end
    end
  end
end
