require "./class"

module Croft
  class Application < Croft::Class
    register("NSApplication")

    class_method "sharedApplication", nil, self, "shared_application"

    instance_method "finishLaunching", nil, nil, "finish_launching"
  end
end
