require "../spec_helper"

module Croft
  describe Date do
    it "can be initialized to the current date and time" do
      Croft::Date.now.should be_a(Croft::Date)
    end

    it "can be initialized in the future" do
      Croft::Date.seconds_from_now(1.0).should be_a(Croft::Date)
    end

    it "can compare times" do
      present = Croft::Date.now
      future = Croft::Date.seconds_from_now(100_f64)

      future.seconds_since(present).should be_close(100.0, 0.1)
    end
  end
end
