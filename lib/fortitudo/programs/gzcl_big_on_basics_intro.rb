# encoding: utf-8
require_relative '../../fortitudo.rb'
require_relative '../programs.rb'

module Fortitudo
  module Programs
    module GZCLBigOnBasicsIntro
      include GZCLRegular

      module_function

     def bench_volume(pr, exrx, nearest_val = 5)
       squat_volume(pr, exrx, nearest_val)
     end

     def deadlift_volume(pr, exrx)
       args = [[0, '6-8', '5-8', 0], [0, 3, 2, 0],
               [0, 75, 85, 0],       [nil, :T2, :T1, nil]]
       volume_weeks(pr)[args][exrx]
     end

     def squat_volume(pr, exrx, nearest_val = 5)
       args = [['4-6', '6-8', '8-10', 3], [5, 4, 3, 10],
               [65, 75, 85, 65],          [:T2, :T2, :T1, :T2]]
       volume_weeks(pr, nearest_val)[args][exrx]
     end

      def t2_press(pr, exs)
        exp   = exerproc(pr)
        vol   = bench_volume(pr, exs[:primary][:press], 2.5)
        bench = exp[exs[:assistance][:bench][0], 3, 8,
                    ->(e, w) { pr[e] + 5 * w }]
        vpull = exp[exs[:assistance][:vpull][0], [5, 6, 7, 3],
                    ['2-4', '2-4', '2-4', '3-6']]
        asst  =
          2.times.map { |w| [:T2, [bench[w], vpull[w]]] } +
          2.times.map { |w| [:T2, [vpull[w+2]]] }

        4.times.map { |w| vol[w] + asst[w] }
      end

      def t3_press(pr, exs)
        exp     = exerproc(pr)
        chest   = exp[exs[:accessory][:chest][0],   3,            '5-10s']
        delts   = exp[exs[:accessory][:delts][0],   [3, 3, 4, 4], 12]
        rdelts  = exp[exs[:accessory][:rdelts][0],  3,            '20-30',
                     ->(e, _w) { pr[e, -1] }]
        triceps = exp[exs[:accessory][:triceps][0], [3, 3, 4, 4], '15-30']
        ->(w) { [:T3, [chest[w], rdelts[w]], :T3, [delts[w], triceps[w]]] }
      end

      def press(pr, exercises)
        t1 = intensity(pr, exercises[:primary][:press], 2.5)
        t2 = t2_press(pr, exercises)
        t3 = t3_press(pr, exercises)
        4.times.map { |w| t1[w] + t2[w] + t3[w] }
      end
    end
  end
end
