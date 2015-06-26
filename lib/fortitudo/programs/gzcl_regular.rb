# encoding: utf-8
require_relative '../programs.rb'

module Fortitudo
  module Programs
    module GZCLRegular
      include GZCLIntroPlus

      module_function

      def intensity(pr, exrx, nearest_val = 5)
        srladder = [[[1, 1, 1, 2], 3], [[2, 2, 2, 3], 2], [[3, 3, 3, 5], 1]]
        inp      = intensityproc(pr, nearest_val)
        Programs.intensity_weeks(exerproc(pr), inp)[srladder][exrx]
      end

      def intensityproc(pr, nearest_val = 5)
        Programs.intensityproc(Rational(85, 100),
                               Rational(25, 1000),
                               nearest_val)[pr]
      end

      def bench_volume(pr, exrx, nearest_val = 5)
        args = [[7, 6, 10, 3],    [5, 4, 3, 10],
                [65, 75, 85, 65], [:T2, :T2, :T1, :T2]]
        volume_weeks(pr, nearest_val)[args][exrx]
      end

      def deadlift_volume(pr, exrx)
        args = [[0, 7, 5, 0],   [0, 3, 2, 0],
                [0, 75, 85, 0], [nil, :T2, :T1, nil]]
        volume_weeks(pr)[args][exrx]
      end

      def squat_volume(pr, exrx)
        args = [[5, 6, 10, 3],    [7, 4, 3, 10],
                [65, 75, 85, 65], [:T2, :T2, :T1, :T2]]
        volume_weeks(pr)[args][exrx]
      end

      def squat2_volume(pr, exrx)
        args = [[5, 4, 4, 0],    [10, 8, 8, 0],
                [50, 60, 70, 0], [:T2, :T2, :T2, nil]]
        volume_weeks(pr)[args][exrx]
      end

      def t2_squat(pr, exs)
        squat_volume(pr, exs[:primary][:squat])
      end

      def t3_squat(pr, exs)
        exp    = exerproc(pr)
        glutes = exp[exs[:accessory][:glutes][0], 3, 10]
        quads  = exp[exs[:accessory][:quads][0], 4, 12]
        vpull  = exp[exs[:assistance][:vpull][1], [3, 3, 4, 4], '4-8']
        2.times.map { |w| [:T3, [glutes[w], quads[w]], :T3, [vpull[w]]] } +
          2.times.map { |w| [:T3, [quads[w+2], vpull[w+2]]] }
      end

      def squat(pr, exercises)
        t1 = intensity(pr, exercises[:primary][:squat])
        t2 = t2_squat(pr, exercises)
        t3 = t3_squat(pr, exercises)
        4.times.map { |w| t1[w] + t2[w] + t3[w] }
      end

      def t2_bench(pr, exs)
        exp   = exerproc(pr)
        vol   = bench_volume(pr, exs[:primary][:bench])
        press = exp[exs[:assistance][:press][0],
                    [3, 4], [10, 6],
                    ->(e, w) { pr[e, 5 * (w+1).div(2)] }]
        row   = exp[exs[:assistance][:row][0], [3, 3, 3, 4], 8]
        asst  =
          2.times.map { |w| [:T2, [press[w], row[w]]] } +
          2.times.map { |w| [:T2, [row[w+2]]] }
        4.times.map { |w| vol[w] + asst[w] }
      end

      def t3_bench(pr, exs)
        exp     = exerproc(pr)
        biceps  = exp[exs[:accessory][:biceps][0],  [3, 3, 4, 4], 12]
        chest   = exp[exs[:accessory][:chest][0],   4,            '5-10s']
        rdelts  = exp[exs[:accessory][:rdelts][0],  4,            '15-30']
        triceps = exp[exs[:accessory][:triceps][0], [3, 3, 4, 4], '20-30',
                     ->(e, _w) { pr[e, -1] }]
        ->(w) { [:T3, [chest[w], rdelts[w]], :T3, [biceps[w], triceps[w]]] }
      end

      def bench(pr, exercises)
        t1 = intensity(pr, exercises[:primary][:bench], 2.50)
        t2 = t2_bench(pr, exercises)
        t3 = t3_bench(pr, exercises)
        4.times.map { |w| t1[w] + t2[w] + t3[w] }
      end

      def t2_deadlift(pr, exs)
        exp    = exerproc(pr)
        vol    = deadlift_volume(pr, exs[:primary][:deadlift])
        fsquat = exp[exs[:assistance][:squat][1], '4-6', 5]
        pull   = exp[exs[:assistance][:pull][0],  3, 10]
        row    = exp[exs[:assistance][:row][1],   [3, 3, 4, 4], 8,
                    ->(e, w) { pr[e] + (w+1).div(2) * 5 }]
        asst   = proc do |w|
          (w.zero? ? [:T2, [fsquat[w]]] : []) +
            ((w < 2) ? [:T2, [pull[w]]] : []) +
            [:T2, [row[w]]]
        end
        4.times.map { |w| vol[w] + asst[w] }
      end

      def t3_deadlift(pr, exs)
        exp   = exerproc(pr)
        hams  = exp[exs[:accessory][:hams][0], [3, 3, 4, 4], '12ea']
        vpull = exp[exs[:assistance][:vpull][0],
                    ->(w) { 3 + w }, '3-6', ->(e, w) { pr[e, 1] }]
        ->(w) { [:T3, [hams[w], vpull[w]]] }
      end

      def deadlift(pr, exercises)
        t1 = intensity(pr, exercises[:primary][:deadlift])
        t2 = t2_deadlift(pr, exercises)
        t3 = t3_deadlift(pr, exercises)
        4.times.map { |w| t1[w] + t2[w] + t3[w] }
      end

      def squat2(pr, exercises)
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        isq   = intensity(pr, primary[:squat])
        isq4  = exp[primary[:squat], '10+', 3,
                    ->(e, _w) { nearest(pr[e] * Rational(9, 10)) }]
        intns = proc do |w|
          (w < 3) ? isq[w] : [:T1, [isq4[w]]]
        end
        vol   = squat2_volume(pr, primary[:squat])

        sasst = exp[->(w) { assistance[:squat][w] }, 3, 8]
        asst  = ->(w) { (w < 2) ? [:T2, [sasst[w]]] : [] }

        vpull = exp[assistance[:vpull][0], [5, 6, 7, 3],
                    ['2-4', '2-4', '2-4', '3-6']]
        accs  = ->(w) { [:T3, [vpull[w]]] }

        4.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] }
      end
    end
  end
end
