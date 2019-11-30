require "../spec_helper"
module Croft
  describe String do
    it "can be initialized with a Crystal string" do
      str = Croft::String.new("hi")
      str2 = Croft::String.new("hiya")

      str.to_s.should eq "hi"
      str2.to_s.should eq "hiya"
    end

    it "can be an empty string" do
      str = Croft::String.new(Croft::String.empty_string)
      str.to_s.should eq ""
    end

    it "has the correct raw value" do
      str = Croft::String.new("abc")
      slice = str.raw_string.to_slice(3)
      bytes = Bytes['a'.ord, 'b'.ord, 'c'.ord]

      slice.should eq bytes
    end

    it "has the correct string value" do
      str = Croft::String.new("dEf")

      str.to_s.should eq("dEf")
    end

    it "handles a nil pointer" do
      str = Croft::String.new(Pointer(UInt8).new(0))

      str.raw_string.to_slice(1).should eq Bytes[0]
      str.to_s.should eq("")
    end
  end
end
