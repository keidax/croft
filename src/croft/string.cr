require "../objc"
require "./class"

module Croft
  class String < Croft::Class
    register("NSString")

    def self.new(str : ::String) : self
      objc_method "stringWithUTF8String:"
    end

    def self.empty : LibObjc::Instance*
      objc_method "string"
    end

    def raw_string : UInt8*
      LibObjc.objc_msgSend(@obj, Selector["UTF8String"]).as(UInt8*)
    end

    def initialize(ptr : Pointer)
      if ptr.null?
        @obj = self.class.empty
      else
        @obj = ptr.as(LibObjc::Instance*)
      end
    end

    def to_s(io)
      io << ::String.new(raw_string)
    end
  end
end
