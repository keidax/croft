require "../objc"

module Croft
  abstract class Class
    @@cls : LibObjc::Class? # Must be nilable?
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

    macro class_method(name, arg_types, return_type, crystal_name = nil)
      {% crystal_name = crystal_name || name.id %}
      {% return_type = return_type || Nil %}
      {% arg_types = arg_types || [] of Nil %}
      def self.{{crystal_name.id}}(
        {% for i in (0...arg_types.size) %}
          arg{{i}} : {{arg_types[i]}},
        {% end %}
      ) : {{ return_type }}
        res = LibObjc.objc_msgSend(
          @@cls,
          Croft::Selector["{{name.id}}"],
        {% for i in (0...arg_types.size) %}
            arg{{i}},
        {% end %}
        )
        {% if return_type.id == "LibObjc::Instance" %}
          res.as(LibObjc::Instance)
        {% elsif return_type != Nil %}
          raise NilAssertionError.new if res.null?
          {{return_type}}.new(res.as(LibObjc::Instance))
        {% end %}
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
        {% if return_type.id != "Nil" %}
          # raise NilAssertionError.new if res.null?
          {{return_type}}.new(res.as(LibObjc::Instance))
        {% end %}
      end
    end
  end
end
