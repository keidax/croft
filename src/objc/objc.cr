require "./*"

@[Link("objc")]
@[Link(framework: "AppKit")]
@[Link(framework: "Foundation")]
lib LibObjc
  type Imp = Void*

  alias BOOL = Int8
  YES = 1_i8
  NO  = 0_i8

  fun msg_send = objc_msgSend(self_ : Void*, op : Selector*, ...) : Void*
  fun msg_send_fpret = objc_msgSend_fpret(self_ : Void*, op : Selector*, ...) : Float64
end
