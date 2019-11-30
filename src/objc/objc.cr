@[Link("objc")]
@[Link(framework: "Foundation")]
lib LibObjc
  type SEL = Void*
  fun sel_registerName(str : UInt8*) : SEL
  fun sel_getName(aSelector : SEL) : UInt8*

  type Class = Void*
  fun objc_getClass(name : UInt8*) : Class

  type Instance = Void*
  fun objc_msgSend(self_ : Void*, op : SEL, ...) : Void*
end
