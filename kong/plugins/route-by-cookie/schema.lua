local typedefs = require "kong.db.schema.typedefs"

local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

return {
  name = plugin_name,
  fields = {
    { consumer = typedefs.no_consumer },
    { config = {
      type = "record",
      fields = {
        { cookie_name = { type = "string", required = true }, },
        { cookie_val = { type = "string", required = true }, },
        { target_upstream = { type = "string", required = true }, },
      },
    }, },
  },
}
