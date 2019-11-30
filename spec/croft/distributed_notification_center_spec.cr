require "../spec_helper"

module Croft
  describe Croft::DistributedNotificationCenter do
    it "has a default center" do
      default = Croft::DistributedNotificationCenter.default_center
      default.should be_a(Croft::DistributedNotificationCenter)
    end

    it "can add an observer" do
      default = Croft::DistributedNotificationCenter.default_center
      foo = Croft::DistributedNotificationCenter.default_center
      default.add_observer(foo, Selector["defaultCenter"], Croft::String.new("asdf"), nil)

      default.post_notification(Croft::String.new("asdf"), nil, nil, true)
    end
  end
end
