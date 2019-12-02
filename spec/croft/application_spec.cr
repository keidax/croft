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
      shared1 = Application.shared_application
      shared2 = Application.shared_application
      shared1.to_unsafe.should eq(shared2.to_unsafe)
    end

    it "can finish launching" do
      delegate = AppDelegate.new
      LibObjc.objc_msgSend(Application.shared_application, Selector["setDelegate:"], delegate)

      Application.shared_application.finish_launching
      chan_result = delegate.chan.receive
      chan_result.should be_true
    end
  end
end
