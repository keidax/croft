require "../spec_helper"

class Testing < Croft::Class
  register("NSLogicalTest") # Just a random class in Foundation
end

module Foo
  class CustomClass < Croft::Class
    export

    property count : Int32 = 0

    export_instance_method "addToCount:", def add_to_count(val : Int32)
      self.count += val
    end
  end
end

module Croft
  describe Class do
    it "can register an existing class" do
      Testing.objc_name.should eq("NSLogicalTest")
    end

    it "can export a Crystal class" do
      Foo::CustomClass.objc_name.should eq("Foo::CustomClass")
    end

    it "can initialize an instance of an exported" do
      foo = Foo::CustomClass.new
      foo.to_unsafe.null?.should be_false

      # TODO is there a better way to get a BOOL result?
      res = LibObjc.msg_send(foo, Selector["isMemberOfClass:"], Foo::CustomClass)
      res.address.should eq(LibObjc::YES)
    end

    it "can define and call exported Crystal methods" do
      foo = Foo::CustomClass.new
      foo.count.should eq 0

      foo.add_to_count(1)
      foo.count.should eq 1

      LibObjc.msg_send(foo, Selector["addToCount:"], 1)
      foo.count.should eq 2
    end
  end
end
