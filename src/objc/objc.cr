@[Link("objc")]
lib LibObjc
  type SEL = Void*
  fun sel_registerName(str : UInt8*) : SEL
  fun sel_getName(aSelector : SEL) : UInt8*

  type Class = Void*
end
