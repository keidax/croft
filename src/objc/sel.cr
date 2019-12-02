require "./objc"

lib LibObjc
  fun sel_registerName(str : UInt8*) : Selector*
  fun sel_getName(aSelector : Selector*) : UInt8*
end

@[Extern]
struct LibObjc::Selector
  def self.[](name : String) : self*
    LibObjc.sel_registerName(name)
  end

  def self.name(sel : self*) : String
    String.new(LibObjc.sel_getName(sel))
  end
end
