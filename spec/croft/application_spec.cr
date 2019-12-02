require "../spec_helper"

class AppDelegate < Croft::Class
  export

  getter chan = Channel(Bool).new

  export_instance_method "applicationWillFinishLaunching:", def will_finish_launching
    # Send on a different fiber, to avoid a deadlock
    spawn do
      self.chan.send(true)
    end
  end
end

module Croft
  describe Application do
    it "has a shared instance" do
      shared_location1 = Application.shared_application.to_unsafe.as(UInt8*)
      shared_location2 = Application.shared_application.to_unsafe.as(UInt8*)
      shared_location1.should eq(shared_location2)
    end

    it "can finish launching" do
      delegate = AppDelegate.new
      LibObjc.msg_send(Application.shared_application, Selector["setDelegate:"], delegate)

      Application.shared_application.finish_launching
      chan_result = delegate.chan.receive
      chan_result.should be_true
    end
  end
end
