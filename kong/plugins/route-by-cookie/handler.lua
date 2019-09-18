local plugin = require("kong.plugins.base_plugin"):extend()

function plugin:new()
  plugin.super.new(self, "route-by-cookie")
end

function plugin:access(config)
  plugin.super.access(self)

  local cookie = require "resty.cookie"
  local ck = cookie:new()
  local cookie_val, err = ck:get(config.cookie_name)

  if cookie_val and cookie_val == config.cookie_val then 
    kong.log.debug("changing upstream to" .. config.target_upstream)
    kong.service.set_upstream(config.target_upstream)
  end
end

plugin.PRIORITY = -1

return plugin
