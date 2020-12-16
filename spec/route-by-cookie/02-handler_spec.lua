local PLUGIN_NAME = "route-by-cookie"
local helpers = require "spec.helpers"

-- create 2 servers to the routed and normal traffic
local fixtures = {
  http_mock = {
    upstream = [[
    server {
      server_name upstream.com;
      listen 16798;
      keepalive_requests     10;

      location = / {
        echo 'rerouted';
      }
    }
    ]],
    normal = [[
    server {
      server_name normal.com;
      listen 16799;
      keepalive_requests     10;

      location = / {
        echo 'normal';
      }
    }
    ]]
  }
}

local function get(client, host, cookie, target)
  local headers = {
    host = host
  }
  if cookie then
    headers.cookie = cookie
  end
  local res = assert(client:get("/", { headers = headers }))
  local body = assert.res_status(200, res)
  assert.equal(target, body)
end
for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

      -- create first service, associated route and upstream
      local service_upstream1 = assert(bp.services:insert({
        name = "upstream_service",
        host = "test1.com",
        port = 80,
      }))
      assert(bp.routes:insert({
        service = service_upstream1,
        hosts = { "test1.com" },
      }))

      local upstream1 = assert(bp.upstreams:insert({
        name = service_upstream1.host,
      }))
      assert(bp.targets:insert({
        upstream = { id = upstream1.id, },
        target = "127.0.0.1:16798",
      }))

      -- create second service, associated route and upstream
      local service_upstream2 = assert(bp.services:insert({
        name = "normal_service",
        host = "test2.com",
        port = 80,
      }))
      assert(bp.routes:insert({
        service = service_upstream2,
        hosts = { "test2.com" },
      }))

      local upstream2 = assert(bp.upstreams:insert({
        name = service_upstream2.host,
      }))
      assert(bp.targets:insert({
        upstream = { id = upstream2.id, },
        target = "127.0.0.1:16799",
      }))

      -- create the main service routing to the first or second one
      local mainroute = assert(bp.routes:insert({
        service = bp.services:insert({
          name = "global",
          host = "test2.com",
          port = 80,
        }),
        hosts = { "test.com" },
      }))

      -- add the plugin to the main route
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = mainroute.id },
        config = {
          target_upstream = upstream1.name,
          cookie_name="foo",
          cookie_val="bar",
        },
      }
      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
      },nil, nil, fixtures))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("request ", function()
      describe("without the cookie set ", function()
        it("on test1", function()
          get(client, "test1.com", nil, "rerouted")
        end)
        it("on test2", function()
          get(client, "test2.com", nil, "normal")
        end)
        it("on test", function()
          get(client, "test.com", nil, "normal")
        end)
      end)

      describe("with the cookie set with the expected value ", function()
        it("on test1", function()
          get(client, "test1.com", "foo=bar", "rerouted")
        end)
        it("on test2", function()
          get(client, "test2.com", "foo=bar", "normal")
        end)
        it("on test", function()
          get(client, "test.com", "foo=bar", "rerouted")
        end)
      end)

      describe("with the cookie set with the expected value and other cookie before ", function()
        it("on test1", function()
          get(client, "test1.com", "bar=bar; foo=bar", "rerouted")
        end)
        it("on test2", function()
          get(client, "test2.com", "bar=bar; foo=bar", "normal")
        end)
        it("on test", function()
          get(client, "test.com", "bar=bar; foo=bar", "rerouted")
        end)
      end)

      describe("with the cookie set with the expected value and other cookie after", function()
        it("on test1", function()
          get(client, "test1.com", "foo=bar; bar=bar", "rerouted")
        end)
        it("on test2", function()
          get(client, "test2.com", "foo=bar; bar=bar", "normal")
        end)
        it("on test", function()
          get(client, "test.com", "foo=bar; bar=bar", "rerouted")
        end)
      end)

      describe("with the cookie set with the expected value and other cookie before and after", function()
        it("on test1", function()
          get(client, "test1.com", "a=b; foo=bar; bar=bar", "rerouted")
        end)
        it("on test2", function()
          get(client, "test2.com", "a=b; foo=bar; bar=bar", "normal")
        end)
        it("on test", function()
          get(client, "test.com", "a=b; foo=bar; bar=bar", "rerouted")
        end)
      end)

      describe("with the cookie set without the expected value ", function()
        it("on test1", function()
          get(client, "test1.com", "foo=foo", "rerouted")
        end)
        it("on test2", function()
          get(client, "test2.com", "foo=foo", "normal")
        end)
        it("on test", function()
          get(client, "test.com", "foo=foo", "normal")
        end)
      end)

      describe("with the cookie set without the expected name ", function()
        it("on test1", function()
          get(client, "test1.com", "bar=bar", "rerouted")
        end)
        it("on test2", function()
          get(client, "test2.com", "bar=bar", "normal")
        end)
        it("on test", function()
          get(client, "test.com", "bar=bar", "normal")
        end)
      end)

    end)
  end)
end
