require "../spec_helper"

module Croft
  describe Application do
    it "has a shared instance" do
      shared1 = Application.shared_application
      shared2 = Application.shared_application
      shared1.to_unsafe.should eq(shared2.to_unsafe)
    end

    it "can finish launching" do
      Application.shared_application.finish_launching
    end
  end
end
