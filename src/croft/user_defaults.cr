require "./class"

module Croft
  class UserDefaults < Croft::Class
    register("NSUserDefaults")

    def self.standard_user_defaults : self
      objc_method "standardUserDefaults"
    end

    def [](key : Croft::String) : Croft::String
      objc_method "stringForKey:"
    end
  end
end
