require "./class"

module Croft
  class DistributedNotificationCenter < Croft::Class
    register("NSDistributedNotificationCenter")

    def self.default : self
      objc_method "defaultCenter"
    end

    def add_observer(observer : Croft::Class, sel : Selector, name : Croft::String, obj : _) : Nil
      objc_method "addObserver:selector:name:object:"
    end

    def post_notification(name : Croft::String, sender : _, user_info : _, immediate : _) : Nil
      objc_method "postNotificationName:object:userInfo:deliverImmediately:"
    end
  end
end
