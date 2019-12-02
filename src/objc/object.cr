require "./objc"

lib LibObjc
  fun object_getIndexedIvars(obj : Instance*) : Void*
end

@[Extern]
struct LibObjc::Instance
  def self.extra_data(obj : self*) : Void*
    LibObjc.object_getIndexedIvars(obj)
  end
end
