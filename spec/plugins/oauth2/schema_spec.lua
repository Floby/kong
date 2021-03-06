local validate_entity = require("kong.dao.schemas_validation").validate_entity
local oauth2_schema = require "kong.plugins.oauth2.schema"

require "kong.tools.ngx_stub"

describe("OAuth2 Entities Schemas", function()

  describe("OAuth2 Configuration", function()

    it("should not require a `scopes` when `mandatory_scope` is false", function()
      local valid, errors = validate_entity({ mandatory_scope = false }, oauth2_schema)
      assert.truthy(valid)
      assert.falsy(errors)
    end)

    it("should require a `scopes` when `mandatory_scope` is true", function()
      local valid, errors = validate_entity({ mandatory_scope = true }, oauth2_schema)
      assert.falsy(valid)
      assert.equal("To set a mandatory scope you also need to create available scopes", errors.mandatory_scope)
    end)

    it("should pass when both `scopes` when `mandatory_scope` are passed", function()
      local valid, errors = validate_entity({ mandatory_scope = true, scopes = { "email", "info" } }, oauth2_schema)
      assert.truthy(valid)
      assert.falsy(errors)
    end)

    it("should autogenerate a `provision_key` when it is not being passed", function()
      local t = { mandatory_scope = true, scopes = { "email", "info" } }
      local valid, errors = validate_entity(t, oauth2_schema)
      assert.truthy(valid)
      assert.falsy(errors)
      assert.truthy(t.provision_key)
      assert.are.equal(32, t.provision_key:len())
    end)

    it("should not autogenerate a `provision_key` when it is being passed", function()
      local t = { mandatory_scope = true, scopes = { "email", "info" }, provision_key = "hello" }
      local valid, errors = validate_entity(t, oauth2_schema)
      assert.truthy(valid)
      assert.falsy(errors)
      assert.truthy(t.provision_key)
      assert.are.equal("hello", t.provision_key)
    end)

  end)

end)
