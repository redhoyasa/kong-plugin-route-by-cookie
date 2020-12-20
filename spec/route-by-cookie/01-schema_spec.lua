local PLUGIN_NAME = "route-by-cookie"
local schema_def = require("kong.plugins."..PLUGIN_NAME..".schema")
local v = require("spec.helpers").validate_plugin_config_schema



describe("Plugin: " .. PLUGIN_NAME .. ": (schema), ", function()
  it("should accept README configuration", function()
    assert(v({
      target_upstream="new-upstream",
      cookie_name="COOKIE_NAME",
      cookie_val="value",
    }, schema_def))

  end)


  describe("Errors: ", function()
    it("should not accept invalid type for `target_upstream`", function()
      local ok, err = v({
        target_upstream= {},
        cookie_name="COOKIE_NAME",
        cookie_val="value",
      }, schema_def)
      assert.falsy(ok)
      assert.same({ target_upstream = "expected a string" }, err.config)
    end)
    it("should not accept if `target_upstream` is missing", function()
      local ok, err = v({
        cookie_name="COOKIE_NAME",
        cookie_val="value",
      }, schema_def)
      assert.falsy(ok)
      assert.same({ target_upstream = "required field missing" }, err.config)
    end)

    it("should not accept invalid type for `cookie_name`", function()
      local ok, err = v({
        target_upstream="new-upstream",
        cookie_name={},
        cookie_val="value",
      }, schema_def)
      assert.falsy(ok)
      assert.same({ cookie_name = "expected a string" }, err.config)
    end)
    it("should not accept if `cookie_name` is missing", function()
      local ok, err = v({
        target_upstream="new-upstream",
        cookie_val="value",
      }, schema_def)
      assert.falsy(ok)
      assert.same({ cookie_name = "required field missing" }, err.config)
    end)

    it("should not accept invalid type for `cookie_val`", function()
      local ok, err = v({
        target_upstream="new-upstream",
        cookie_name="COOKIE_NAME",
        cookie_val={},
      }, schema_def)
      assert.falsy(ok)
      assert.same({ cookie_val = "expected a string" }, err.config)
    end)
    it("should not accept if `cookie_val` is missing", function()
      local ok, err = v({
        target_upstream="new-upstream",
        cookie_name="COOKIE_NAME",
      }, schema_def)
      assert.falsy(ok)
      assert.same({ cookie_val = "required field missing" }, err.config)
    end)
  end)


end)
