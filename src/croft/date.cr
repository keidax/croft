require "./class"

module Croft
  class Date < Croft::Class
    register("NSDate")

    class_method "date", nil, self, "now"
    class_method "dateWithTimeIntervalSinceNow:", [Float64], self, "seconds_from_now"

    instance_method "timeIntervalSinceDate:", [self], Float64, "seconds_since"
  end
end
