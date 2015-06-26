# encoding: utf-8
require_relative '../programs.rb'

module Fortitudo
  module Programs
    module GZCLRegularPlus
      include GZCLRegular

      module_function

      def intensity(pr, exrx, nearest_val = 5)
        srladder = [1, 3, "5+"].map { |r| 4.times.map { r } }.zip([3, 2, 1])
        inp      = intensityproc(pr, nearest_val)
        Programs.intensity_weeks(exerproc(pr), inp)[srladder][exrx]
      end

      def intensityproc(pr, nearest_val = 5)
        Programs.intensityproc(Rational(875, 1000),
                               Rational(25, 1000),
                               nearest_val)[pr]
      end

      def bench_volume(pr, exrx, nearest_val = 5)
        squat_volume(pr, exrx, nearest_val)
      end

      def deadlift_volume(pr, exrx, nearest_val = 5)
        args = [[0, 7, 5, 0],   [0, 3, 2, 0],
                [0, 75, 85, 0], [nil, :T2, :T1, nil]]
        volume_weeks(pr, nearest_val)[args][exrx]
      end

      def squat_volume(pr, exrx, nearest_val = 5)
        args = [[3, 5, 3, 7],     [8, 5, 8, 5],
                [65, 70, 75, 80], [:T2, :T2, :T2, :T2]]
        volume_weeks(pr, nearest_val)[args][exrx]
      end
    end
  end
end
