require "./class"

module Croft
  class Application < Croft::Class
    register("NSApplication")

    def self.shared_application : self
      objc_method "sharedApplication"
    end

    def finish_launching : Nil
      objc_method "finishLaunching"
    end
  end
end
