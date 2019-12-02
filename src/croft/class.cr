require "../objc"

module Croft
  abstract class Class
    # Get around nilability check for class variables
    @@cls : LibObjc::Class* = Pointer(LibObjc::Class).null
    @obj : LibObjc::Instance*

    @@ivar_set = false

    def self.register(name : ::String)
      @@cls = LibObjc.objc_getClass(name)
      raise NilAssertionError.new if !@@cls
    end

    def self.to_unsafe
      @@cls
    end

    def to_unsafe
      @obj
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
      new_obj = LibObjc.objc_msgSend(@@cls, Selector["new"])
      @obj = new_obj.as(LibObjc::Instance*)
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

    macro objc_method(objc_name)
      # Get the concrete return type
      {% if @def.return_type.id == "self" %}
        {% ret_type = @type %}
      {% else %}
        {% ret_type = @def.return_type.resolve %}
      {% end%}

      # Make a call to objc_msgSend
      res = {% if ret_type == Float64 %}
              LibObjc.objc_msgSend_fpret(
            {% else %}
              LibObjc.objc_msgSend(
            {% end %}
              self,
              Croft::Selector[{{objc_name}}],
              {{ @def.args.map(&.internal_name).splat }}
            )

      # Cast to the right return type
      {% if ret_type == Nil %}
        nil
      {% elsif ret_type == Float64 %}
        res
      {% elsif ret_type < Pointer %}
        res.as({{ret_type.id}})
      {% else %}
        {% unless ret_type == Croft::String %}
          # Handle a nil string as empty string. Otherwise, raise on nil
          raise NilAssertionError.new if res.null?
        {% end %}

        {{@def.return_type}}.new(res.as(LibObjc::Instance*))
      {% end %}
    end

    macro export_instance_method(name, definition)
      {{ definition }}

      imp = ->(self_ : LibObjc::Instance*, op : LibObjc::SEL, {{ definition.args.splat }}) do
        # Convert object_id back into object reference
        obj_id = LibObjc.object_getIndexedIvars(self_).as(UInt64*)
        obj = Pointer(self).new(obj_id.value).as(self)
        obj.{{ definition.name.id }}({{ definition.args.map(&.name).splat }})
      end

      LibObjc.class_addMethod(@@cls, Croft::Selector["{{name.id}}"], imp.pointer.as(LibObjc::Imp), "v@:")
    end
  end
end
