require "../spec_helper"

describe "LibObjc" do
  describe "Selector" do
    it "can be registered" do
      selector = LibObjc.sel_registerName("HI")
      selector.should_not be_nil
      selector.should be_a(Pointer(LibObjc::Selector))
    end

    it "can be registered multiple times" do
      sel1 = LibObjc.sel_registerName("sel1")
      sel2 = LibObjc.sel_registerName("sel2")
      sel1_again = LibObjc.sel_registerName("sel1")

      sel1.should eq(sel1_again)
      sel1.should_not eq(sel2)
    end
  end
end
