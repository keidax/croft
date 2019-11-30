require "./class"

module Croft
  class UserDefaults < Croft::Class
    register("NSUserDefaults")

    class_method "standardUserDefaults", nil, self, "standard_user_defaults"

    instance_method "stringForKey:", [Croft::String], Croft::String, "string_for_key"
  end
end
