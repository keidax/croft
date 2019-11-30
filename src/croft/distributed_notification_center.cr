require "./class"

module Croft
  class DistributedNotificationCenter < Croft::Class
    register("NSDistributedNotificationCenter")

    class_method "defaultCenter", nil, self, "default_center"
    instance_method "addObserver:selector:name:object:",
      [_, Croft::Selector, Croft::String, _],
      Nil,
      "add_observer"

    instance_method "postNotificationName:object:userInfo:deliverImmediately:",
      [Croft::String, _, _, _],
      Nil,
      "post_notification"
  end
end
