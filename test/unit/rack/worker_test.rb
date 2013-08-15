require 'test_helper'
require 'stringio'

module Librato
  class Rack
    class WorkerTest < Minitest::Test

      def test_basic_use
        worker = Worker.new
        counter = 0
        Thread.new do
          worker.run_periodically(0.1) do
            counter += 1
          end
        end
        sleep 0.45
        assert_equal counter, 4
      end

      def test_start_time
        worker = Worker.new

        20.times do
          time = Time.now
          start = worker.start_time(60)
          assert start >= time + 1, 'should be more than 1 second from when run'
          assert start <= time + 120, 'should not be more than 60 seconds from when run'
        end
      end

      def test_start_time_with_sync
        worker = Worker.new(sync: true)

        time = Time.now
        start = worker.start_time(60)
        assert start >= time + 60, 'should be more than 60 seconds from when run'
        assert_equal 0, start.sec, 'should start on a whole minute'

        time = Time.now
        start = worker.start_time(10)
        assert start >= time + 10, 'should be more than 10 seconds from when run'
        assert_equal 0, start.sec%10, 'should be evenly divisible with whole minutes'
      end

      def test_timer_type
        worker = Worker.new
        assert_equal :sleep, worker.timer

        em_worker = Worker.new(:timer => 'eventmachine')
        assert_equal :eventmachine, em_worker.timer

        # tolerate explicit nils
        worker = Worker.new(:timer => nil)
        assert_equal :sleep, worker.timer
      end

    end
  end
end