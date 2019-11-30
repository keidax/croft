require "../objc"
require "./class"

module Croft
  class String < Croft::Class
    register("NSString")

    class_method "stringWithUTF8String:", [::String], self, "new"

    def raw_string : UInt8*
      LibObjc.objc_msgSend(@obj.as(Void*), Selector["UTF8String"]).as(UInt8*)
    end

    def to_s(io)
      io << ::String.new(raw_string)
    end
  end
end
