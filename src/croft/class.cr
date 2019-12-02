require "../objc"

module Croft
  abstract class Class
    # Get around nilability check for class variables
    NIL_CLASS = Pointer(Void).new(0).as(LibObjc::Class)

    @@cls : LibObjc::Class = NIL_CLASS
    @obj : LibObjc::Instance

    @@ivar_set = false

    def self.register(name : ::String)
      @@cls = LibObjc.objc_getClass(name)
      raise NilAssertionError.new if !@@cls
    end

    def self.to_unsafe
      @@cls
    end

    def to_unsafe : Void*
      @obj.as(Void*)
    end

    def self.objc_name : ::String
      ::String.new(LibObjc.class_getName(@@cls))
    end

    # Initialize with an existing pointer
    def initialize(@obj)
      raise NilAssertionError.new if @obj.null?

      assign_self_ivar
    end

    # Initialize a new object
    def initialize
      new_obj = LibObjc.objc_msgSend(@@cls.as(Void*), Selector["new"])
      @obj = new_obj.as(LibObjc::Instance)
      raise NilAssertionError.new if @obj.null?

      assign_self_ivar
    end

    # Store reference to crystal object in objc object.
    # Storing the object_id is the simplest way to get a pointer back.
    private def assign_self_ivar
      return unless @@ivar_set
      obj_ptr = LibObjc.object_getIndexedIvars(@obj).as(UInt64*)
      obj_ptr.value = object_id
    end

    # Register Objective-C version of the class
    def self.export(name : String? = nil)
      superclass = LibObjc.objc_getClass("NSObject")
      name ||= self.name
      # Add extra space for a pointer to crystal object
      @@cls ||= LibObjc.objc_allocateClassPair(superclass, name.to_unsafe, extra_bytes: sizeof(UInt64))
      LibObjc.objc_registerClassPair(@@cls)
      @@ivar_set = true
    end

    private macro return_helper(return_type)
      {% if return_type.id == "LibObjc::Instance" %}
        res.as(LibObjc::Instance)

      {% elsif return_type.id == "Float64" %}
        res
      {% elsif return_type.id != "Nil" %}
        {% unless return_type.id == "Croft::String" %}
          # Handle a nil string as empty string. Otherwise, raise on nil
          raise NilAssertionError.new if res.null?
        {%end%}

        {{return_type}}.new(res.as(LibObjc::Instance))
      {% end %}
    end

    macro class_method(name, arg_types, return_type, crystal_name = nil)
      {% crystal_name = crystal_name || name.id %}
      {% return_type = return_type || Nil %}
      {% arg_types = arg_types || [] of Nil %}
      def self.{{crystal_name.id}}(
        {% for i in (0...arg_types.size) %} arg{{i}} : {{arg_types[i]}}, {% end %}
      ) : {{ return_type }}
        res = LibObjc.objc_msgSend(
          @@cls.as(Void*),
          Croft::Selector["{{name.id}}"],
          {% for i in (0...arg_types.size) %} arg{{i}}, {% end %}
        )

        return_helper({{return_type}})
      end
    end

    macro instance_method(name, arg_types, return_type, crystal_name = nil)
      {% crystal_name = crystal_name || name.id %}
      {% return_type = return_type || Nil %}
      {% arg_types = arg_types || [] of Nil %}
      def {{crystal_name.id}}(
        {% for i in (0...arg_types.size) %} arg{{i}} : {{arg_types[i]}}, {% end %}
      ) : {{ return_type }}
        res = LibObjc.objc_msgSend{% if return_type.id == "Float64" %}_fpret{% end %}(
          @obj.as(Void*),
          Croft::Selector["{{name.id}}"],
          {% for i in (0...arg_types.size) %} arg{{i}}, {% end %}
        )

        return_helper({{return_type}})
      end
    end

    macro export_instance_method(name, definition)
      {{ definition }}

      imp = ->(self_ : LibObjc::Instance, op : LibObjc::SEL, {{ definition.args.splat }}) do
        # Convert object_id back into object reference
        obj_id = LibObjc.object_getIndexedIvars(self_).as(UInt64*)
        obj = Pointer(self).new(obj_id.value).as(self)
        obj.{{ definition.name.id }}({{ definition.args.map(&.name).splat }})
      end

      LibObjc.class_addMethod(@@cls, Croft::Selector["{{name.id}}"], imp.pointer.as(LibObjc::Imp), "v@:")
    end
  end
end
