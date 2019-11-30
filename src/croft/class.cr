require "../objc"

module Croft
  abstract class Class
    # Get around nilability check for class variables
    NIL_CLASS = Pointer(Void).new(0).as(LibObjc::Class)

    @@cls : LibObjc::Class = NIL_CLASS
    @obj : LibObjc::Instance

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

    def initialize(@obj)
      raise NilAssertionError.new if @obj.null?
    end

    private macro return_helper(return_type)
      {% if return_type.id == "LibObjc::Instance" %}
        res.as(LibObjc::Instance)
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
        res = LibObjc.objc_msgSend(
          @obj.as(Void*),
          Croft::Selector["{{name.id}}"],
          {% for i in (0...arg_types.size) %} arg{{i}}, {% end %}
        )

        return_helper({{return_type}})
      end
    end
  end
end
