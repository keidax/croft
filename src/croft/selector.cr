require "../objc"

module Croft
  class Selector
    @sel : LibObjc::Selector*

    def self.[](str : ::String)
      self.new(str)
    end

    def initialize(str : ::String)
      @sel = LibObjc::Selector[str]
    end

    def initialize(@sel); end

    def to_s(io)
      io << "<SEL:#{LibObjc::Selector.name(@sel)}>"
    end

    def to_unsafe
      @sel
    end
  end
end
