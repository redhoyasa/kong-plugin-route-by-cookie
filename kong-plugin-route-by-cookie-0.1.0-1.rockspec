package = "kong-plugin-route-by-cookie"
version = "0.1.0-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.route-by-cookie.handler"] = "kong/plugins/route-by-cookie/handler.lua",
      ["kong.plugins.route-by-cookie.schema"] = "kong/plugins/route-by-cookie/schema.lua"
   }
}
