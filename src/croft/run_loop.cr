require "./class"

module Croft
  class RunLoop < Croft::Class
    register("NSRunLoop")

    def self.current : self
      objc_method "currentRunLoop"
    end

    def run_until(date : Croft::Date) : Nil
      objc_method "runUntilDate:"
    end
  end
end
