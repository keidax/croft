require "../objc"

module Croft
  abstract class Class
    # Get around nilability check for class variables
    @@cls : LibObjc::Class* = Pointer(LibObjc::Class).null
    @obj : LibObjc::Instance*

    @@ivar_set = false

    def self.register(name : ::String)
      @@cls = LibObjc::Class.get(name)
      raise NilAssertionError.new if !@@cls
    end

    def self.to_unsafe
      @@cls
    end

    def to_unsafe
      @obj
    end

    def self.objc_name : ::String
      LibObjc::Class.name(@@cls)
    end

    # Initialize with an existing pointer
    def initialize(@obj)
      raise NilAssertionError.new if @obj.null?

      assign_self_ivar
    end

    # Initialize a new object
    def initialize
      new_obj = LibObjc.msg_send(@@cls, Selector["new"])
      @obj = new_obj.as(LibObjc::Instance*)
      raise NilAssertionError.new if @obj.null?

      assign_self_ivar
    end

    # Store reference to crystal object in objc object.
    # Storing the object_id is the simplest way to get a pointer back.
    private def assign_self_ivar
      return unless @@ivar_set
      obj_ptr = LibObjc::Instance.extra_data(@obj).as(UInt64*)
      obj_ptr.value = object_id
    end

    # Register Objective-C version of the class
    def self.export(name : String? = nil)
      superclass = LibObjc::Class.get("NSObject")
      name ||= self.name
      # Add extra space for a pointer to crystal object
      @@cls ||= LibObjc::Class.allocate(superclass, name, extra_bytes: sizeof(UInt64))
      LibObjc::Class.register(@@cls)
      @@ivar_set = true
    end

    macro objc_method(objc_name)
      # Get the concrete return type
      {% if @def.return_type.id == "self" %}
        {% return_type = @type %}
      {% else %}
        {% return_type = @def.return_type.resolve %}
      {% end %}

      LibObjc::Msg.send(
        instance: self,
        name: {{objc_name}},
        return_type: {{return_type}},
        {% if @def.args.size > 0  %}
          args: {{@def.args.map(&.internal_name)}},
        {%else%}
          args: [] of Nil,
        {%end%}
      )
    end

    macro export_instance_method(name, definition)
      {{ definition }}

      imp = ->(self_ : LibObjc::Instance*, op : LibObjc::Selector*, {{ definition.args.splat }}) do
        # Convert object_id back into object reference
        obj_id = LibObjc::Instance.extra_data(self_).as(UInt64*)
        obj = Pointer(self).new(obj_id.value).as(self)
        obj.{{ definition.name.id }}({{ definition.args.map(&.name).splat }})
      end

      # NOTE: type encoding doesn't seem to matter here
      unless LibObjc::Class.add_method(@@cls, "{{name.id}}", imp, "v@:")
        raise "couldn't add method"
      end
    end
  end
end
