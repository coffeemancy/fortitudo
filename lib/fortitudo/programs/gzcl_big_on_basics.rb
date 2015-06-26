# encoding: utf-8
require_relative '../programs.rb'

module Fortitudo
  module Programs
    module GZCLBigOnBasics
      include GZCLRegularPlus

      module_function

      def squat(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns  = intensity(pr, primary[:squat])
        vol    = squat_volume(pr, primary[:squat])

        percps = [800, 825, 875, 800].map { |d| Rational(d, 1000) }
        psquat = exp[assistance[:squat][1],
                     [3, 4, 3, 5], [3, 2, 1, 3],
                     ->(_e, w) { nearest(pr[primary[:squat]] * percps[w]) }]
        asst   = 4.times.map { |w| [:T2, [psquat[w]]] }

        glutes = exp[accessory[:glutes][0], 4, [12, 12, 8, 8],
                     ->(e, w) { pr[e] + 10 * w.div(2) }]
        vpull  = exp[assistance[:vpull][0], [4, 5, 6, '6+'], '3-6',
                     ->(e, w) { pr[e, 1] }]
        accs   =
          2.times.map { |w| [:T3, [glutes[w], vpull[w]]] } +
          2.times.map { |w| [:T2, [glutes[w+2]], :T3, [vpull[w+2]]] }

        4.times.map { |w| intns[w] + vol[w] + accs[w] }
      end

      def bench(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns  = intensity(pr, primary[:bench], 2.50)
        vol    = bench_volume(pr, primary[:bench])

        press  = exp[assistance[:press][0],
                     [4, 4, 5], [12, 8, 5],
                     ->(e, w) { pr[e] + 5 * w }]
        row    = exp[assistance[:row][0], '3+', '10ea']
        asst   =
          [[:T3, [press[0], row[0]]]] +
          2.times.map { |w| [:T2, [press[w+1]], :T3, [row[w+1]]] }

        chest  = exp[accessory[:chest][0],  [5, 5, 5, '5+'], 10]
        rdelts = exp[accessory[:rdelts][0], 4, '15-30']
        accs   = ->(w) { [:T3, [chest[w], rdelts[w]]] }

        3.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] } +
          [intns[3] + vol[3] + accs[3]]
      end

      def deadlift(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns = intensity(pr, primary[:deadlift])

        pull  = exp[assistance[:pull][0],  [3, 5, 3, 7], [8, 5, 8, 5],
                    ->(e, w) { pr[e] + 10 * w.modulo(2) }]
        vpull = exp[assistance[:vpull][0], [4, 5, 6, '6+'],
                    ['2-4', '2-4', '2-4', '3-6']]
        row   = exp[assistance[:row][1],   [5, 4, 3, 5], [5, 8, 10, 10],
                    ->(e, w) { pr[e] - 20 * w.div(3) }]
        asst  =
          3.times.map { |w| [:T2, [pull[w], vpull[w]], :T2, [row[w]]] } +
          [[:T2, [pull[3], vpull[3]], :T3, [row[3]]]]

        hams  = exp[accessory[:hams][0], 4, '12ea']
        accs  = ->(w) { [:T3, [hams[w]]] }

        3.times.map { |w| intns[w] + asst[w] + accs[w] } +
          [intns[3] + asst[3]]
      end

     def press(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns  = intensity(pr, primary[:press], 2.5)
        vol    = bench_volume(pr, primary[:press], 2.5)

        bench  = exp[assistance[:bench][0],
                     [4, 4, 5], [12, 8, 5],
                      ->(e, w) { pr[e] + 10 * w }]
        asst   = 3.times.map { |w| [:T2, [bench[w]]] }

        delts   = exp[accessory[:delts][0],   [3, 3, 4, 4], 12]
        rdelts  = exp[accessory[:rdelts][0],  4, '15-30']
        triceps = exp[accessory[:triceps][0], [3, 3, 4, 4], '15-30']
        accs   = ->(w) { [:T3, [rdelts[w]], :T3, [delts[w], triceps[w]]] }

        3.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] } +
         [intns[3] + vol[3] + accs[3]]
      end

      def front_squat(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns   = intensity(pr, primary[:front_squat])
        vol     = squat_volume(pr, primary[:front_squat])

        lunge   = exp[assistance[:squat][0],
                      [4, 4, 5], [12, 8, 5],
                      ->(e, w) { pr[e] + 10 * w }]

        vpull  = exp[assistance[:vpull][0], 4, '3-6',
                     ->(e, w) { pr[e, 1] }]
        asst    =
          3.times.map { |w| [:T2, [lunge[w], vpull[w]]] } +
          [[:T3, [vpull[3]]]]

        biceps  = exp[accessory[:biceps][0],  [3, 3, 4, 4], 12]
        quads   = exp[accessory[:quads][0],   4, '12ea']
        accs    = ->(w) { [:T3, [biceps[w], quads[w]]] }

        4.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] }
      end
    end
  end
end
