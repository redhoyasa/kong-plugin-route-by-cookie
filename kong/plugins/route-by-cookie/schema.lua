return {
  no_consumer = true,
  fields = {
    cookie_name = {type = "string", required = true},
    cookie_val = {type = "string", required = true},
    target_upstream = {type = "string", required = true}
  }
}
