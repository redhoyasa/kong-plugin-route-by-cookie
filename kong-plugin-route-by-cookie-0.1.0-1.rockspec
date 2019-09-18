package = "kong-plugin-route-by-cookie"
version = "0.1.0-1"
source = {
   url = "git://github.com/redhoyasa/kong-plugin-route-by-cookie.git"
}
description = {
   summary = "This kong plugin allows you to dynamically change upstream url based on cookies.",
   homepage = "https://github.com/redhoyasa/kong-plugin-route-by-cookie",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.route-by-cookie.handler"] = "kong/plugins/route-by-cookie/handler.lua",
      ["kong.plugins.route-by-cookie.schema"] = "kong/plugins/route-by-cookie/schema.lua"
   }
}
