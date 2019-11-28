require "../spec_helper"

describe Croft::Selector do
  it "can be created from a string" do
    selector = Croft::Selector.new("hi")
    selector.should_not be_nil
  end

  it "can be created from a raw SEL" do
    sel = LibObjc.sel_registerName("raw")
    selector = Croft::Selector.new(sel)
    selector.should_not be_nil
  end

  it "has a string representation" do
    selector1 = Croft::Selector.new(LibObjc.sel_registerName("sel1"))
    selector2 = Croft::Selector.new("sel2")

    selector1.to_s.should eq("<SEL:sel1>")
    selector2.to_s.should eq("<SEL:sel2>")
  end
end
