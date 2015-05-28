# encoding: utf-8
require './fortitudo.rb'

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

    def intensityproc(start, inc = Rational(25, 1000))
      # takes a pr proc
      proc do |pr|
        # takes a 'n' as 'nth exercise in ladder'
        proc do |n|
          # returns proc taking exercise and week, e.g. for exerproc
          ->(e, w) { nearest(pr[e] * (start + (w + n) * inc)) }
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

    def volume_weeks(exp, pr)
      proc do |sets, reps, percs, tiers|
        proc do |exrx|
          vol = exp[exrx, sets, reps,
                    ->(e, w) { nearest(pr[e] * Rational(percs[w], 100)) }]
          ->(w) { sets[w].zero? ? [] : [tiers[w], [vol[w]]] }
        end
      end
    end

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

      def volume_weeks(pr)
        Programs.volume_weeks(exerproc(pr), pr)
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

    module GZCLRegular
      include GZCLIntroPlus

      module_function

      def intensity(pr, exrx)
        srladder = [[[1, 1, 1, 2], 3], [[2, 2, 2, 3], 2], [[3, 3, 3, 5], 1]]
        Programs.
          intensity_weeks(exerproc(pr), intensityproc(pr))[srladder][exrx]
      end

      def intensityproc(pr)
        Programs.intensityproc(Rational(85, 100))[pr]
      end

      def bench_volume(pr, exrx)
        args = [[7, 6, 10, 3],    [5, 4, 3, 10],
                [65, 75, 85, 65], [:T2, :T2, :T1, :T2]]
        volume_weeks(pr)[args][exrx]
      end

      def deadlift_volume(pr, exrx)
        args = [[0, 7, 5, 0],   [0, 3, 2, 0],
                [0, 75, 85, 0], [nil, :T2, :T1, nil]]
        volume_weeks(pr)[args][exrx]
      end

      def press_volume(pr, exrx)
        squat2_volume(pr, exrx)
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

      def squat(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns  = intensity(pr, primary[:squat])
        vol    = squat_volume(pr, primary[:squat])

        glutes = exp[accessory[:glutes][0], 3, '12-15']
        vpull  = exp[assistance[:vpull][0], 3, '3-6', ->(e, w) { pr[e, 1] }]
        accs   = 2.times.map { |w| [:T3, [glutes[w], vpull[w]]] } +
          2.times.map { |w| [:T3, [vpull[w]]] }

        4.times.map { |w| intns[w] + vol[w] + accs[w] }
      end

      def bench(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns   = intensity(pr, primary[:bench])
        vol     = bench_volume(pr, primary[:bench])

        press = exp[assistance[:press][0],
                    [3, 4], [10, 6],
                    ->(e, w) { pr[e, 5 * w.div(2)] }]
        row   = exp[assistance[:row][0], [3, 3, 3, 4], 8]
        asst  =
          2.times.map { |w| [:T2, [press[w], row[w]]] } +
          2.times.map { |w| [:T2, [row[w+2]]] }

        biceps  = exp[accessory[:biceps][0],  [3, 3, 4, 4], 12]
        triceps = exp[accessory[:triceps][0], [3, 3, 4, 4], '15-30']
        accs    = proc do |w|
          [:T3, [biceps[w], triceps[w]]]
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

        fsquat = exp[assistance[:squat][1], 7, 5]
        pull   = exp[assistance[:pull][0],  3, 10]
        row    = exp[assistance[:row][1],   [3, 3, 4, 4], 8]

        asst   = proc do |w|
          (w.zero? ? [:T2, [fsquat[w]]] : []) +
            ((w < 2) ? [:T2, [pull[w]]] : []) +
            [:T2, [row[w]]]
        end

        hams  = exp[accessory[:hams][0], [3, 3, 4, 4], '12ea']
        vpull = exp[assistance[:vpull][0],
                    ->(w) { 2 + w }, '3-6', ->(e, w) { pr[e, 1] }]
        accs  = ->(w) { [:T3, [hams[w], vpull[w]]] }

        4.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] }
      end

      def press(pr, exercises)
        accessory  = exercises[:accessory]
        assistance = exercises[:assistance]
        primary    = exercises[:primary]
        exp        = exerproc(pr)

        intns   = intensity(pr, primary[:press])
        vol     = press_volume(pr, primary[:press])

        bench = exp[assistance[:bench][0], 3, 8]
        vpull = exp[assistance[:vpull][0], [5, 6, 7, 3],
                    ['2-4', '2-4', '2-4', '3-6']]
        asst  =
          2.times.map { |w| [:T2, [bench[w], vpull[w]]] } +
          2.times.map { |w| [:T2, [vpull[w+2]]] }

        delts  = exp[accessory[:delts][0],  [3, 3, 4, 4], 12]
        rdelts = exp[accessory[:rdelts][0], [3, 3, 4, 4], '15-30']
        accs    = proc do |w|
          [:T3, [delts[w], rdelts[w]]]
        end

        4.times.map { |w| intns[w] + vol[w] + asst[w] + accs[w] }
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
