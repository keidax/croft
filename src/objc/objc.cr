@[Link("objc")]
@[Link(framework: "Foundation")]
lib LibObjc
  type SEL = Void*
  fun sel_registerName(str : UInt8*) : SEL
  fun sel_getName(aSelector : SEL) : UInt8*

  type Class = Void*
  fun objc_getClass(name : UInt8*) : Class
  fun objc_allocateClassPair(superclass : Class, name : UInt8*, extra_bytes : LibC::SizeT ) : Class
  fun objc_registerClassPair(klass : Class)
  fun class_getName(klass : Class): UInt8*
  fun object_getIndexedIvars(obj : Instance) : Void*

  alias BOOL = Int8
  YES = 1_i8
  NO = 0_i8

  type Instance = Void*
  fun objc_msgSend(self_ : Void*, op : SEL, ...) : Void*

  type Imp = Void*
  fun class_addMethod(klass : Class, name : SEL, imp : Imp, types : UInt8*) # TODO return BOOL
end
