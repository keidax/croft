require "../objc"

module Croft
  class Selector
    @sel : LibObjc::SEL

    def initialize(str : String)
      @sel = LibObjc.sel_registerName(str)
    end

    def initialize(@sel); end

    def to_s(io)
      name = LibObjc.sel_getName(@sel)
      io << "<SEL:#{String.new(name)}>"
    end
  end
end
