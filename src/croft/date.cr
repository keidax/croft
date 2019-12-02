require "./class"

module Croft
  class Date < Croft::Class
    register("NSDate")

    def self.now : self
      objc_method "date"
    end

    def self.from_now(seconds : Float64) : self
      objc_method "dateWithTimeIntervalSinceNow:"
    end

    def seconds_since(other : self) : ::Float64
      objc_method "timeIntervalSinceDate:"
    end
  end
end
