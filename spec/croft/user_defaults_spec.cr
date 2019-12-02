require "../spec_helper"

module Croft
  describe UserDefaults do
    it "has defaults" do
      defaults = UserDefaults.standard_user_defaults
      style = defaults[Croft::String.new("AppleInterfaceStyle")]
      # Depends on user settings
      ["", "Dark"].should contain(style.to_s)
    end
  end
end
