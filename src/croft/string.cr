require "../objc"
require "./class"

module Croft
  class String < Croft::Class
    register("NSString")

    class_method "stringWithUTF8String:", [::String], self, "new"
    class_method "string", nil, LibObjc::Instance, "empty_string"

    def raw_string : UInt8*
      LibObjc.objc_msgSend(@obj.as(Void*), Selector["UTF8String"]).as(UInt8*)
    end

    def initialize(ptr : Pointer)
      if ptr.null?
        @obj = self.class.empty_string
      else
        @obj = ptr.as(LibObjc::Instance)
      end
    end

    def to_s(io)
      io << ::String.new(raw_string)
    end
  end
end
