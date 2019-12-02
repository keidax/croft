require "../spec_helper"

module Croft
  describe RunLoop do
    it "has the current run loop" do
      RunLoop.current.should be_a(RunLoop)
    end
    it "can run until a specified time" do
      split_second = Date.from_now(0.05)
      RunLoop.current.run_until(split_second)

      Date.now.seconds_since(split_second).should be_close(0, 0.01)
    end
  end
end
