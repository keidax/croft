require "./objc"

lib LibObjc
  fun objc_getClass(name : UInt8*) : Class*
  fun objc_allocateClassPair(superclass : Class*, name : UInt8*, extra_bytes : LibC::SizeT) : Class*
  fun objc_registerClassPair(klass : Class*)
  fun class_addMethod(klass : Class*, name : Selector*, imp : Imp, types : UInt8*) : BOOL
  fun class_getName(klass : Class*) : UInt8*
end

@[Extern]
struct LibObjc::Class
  def self.get(name : String) : self*
    LibObjc.objc_getClass(name)
  end

  def self.register(klass : self*) : Void
    LibObjc.objc_registerClassPair(klass)
  end

  def self.allocate(superklass : self*, name : String, extra_bytes : Int) : self*
    LibObjc.objc_allocateClassPair(superklass, name, extra_bytes)
  end

  def self.name(klass : self*) : String
    String.new(LibObjc.class_getName(klass))
  end

  def self.add_method(klass : self*, name : String, imp : Proc, types : String) : Bool
    imp = imp.pointer.as(LibObjc::Imp)
    LibObjc.class_addMethod(klass, LibObjc::Selector[name], imp, types) != 0
  end
end
