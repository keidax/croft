require "./*"

@[Link("objc")]
@[Link(framework: "AppKit")]
@[Link(framework: "Foundation")]
lib LibObjc
  type Imp = Void*
  alias BOOL = Int8

  fun msg_send = objc_msgSend(self_ : Void*, op : Selector*, ...) : Void*
  fun msg_send_fpret = objc_msgSend_fpret(self_ : Void*, op : Selector*, ...) : Float64
end

module LibObjc::Msg
  alias Instance = LibObjc::Instance* | LibObjc::Class*

  macro send(instance, name, args, return_type)
    {% return_type = return_type.resolve %}
    begin
      # Make a call to objc_msgSend
      res = {% if return_type == Float64 %}
              LibObjc.msg_send_fpret(
            {% else %}
              LibObjc.msg_send(
            {% end %}
              {{instance}},
              Croft::Selector[{{name}}],
              {{ args.splat }}
            )

      # Cast to the right return type
      {% if return_type == Nil %}
        nil
      {% elsif return_type == Float64 %}
        res
      {% elsif return_type == Bool %}
        res != 0
      {% elsif return_type < Pointer %}
        res.as({{return_type.id}})
      {% else %}
        {% unless return_type == Croft::String %}
          # Handle a nil string as empty string. Otherwise, raise on nil
          raise NilAssertionError.new if res.null?
        {% end %}

        {{@def.return_type}}.new(res.as(LibObjc::Instance*))
      {% end %}
    end
  end
end
