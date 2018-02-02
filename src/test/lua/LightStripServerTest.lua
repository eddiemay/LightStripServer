dofile("Bootstrap.lua")
dofile("TestingBootstrap.lua")
dofile("LightStripServer.lua")

local testObj = {
  name = "TestObj",
  execute = function(self)
    print(self.name)
  end
}

testObj:execute()

print(sjson.encode(testObj))

test("Light Strip API Server", function()
  local conn = MockConnection:new()

  test("System create, get, list, update and delete are not allowed", function()
    net.server:connect(conn)
    conn:receive("PUT /api/system HTTP/1.1")
    conn:receive("{\"entity\": {\"name\": \"Big Power\"}}")
    assertEquals("HTTP/1.1 405 Method Not Allowed\n", conn.messages[1])

    net.server:connect(conn)
    conn:receive("GET /api/system HTTP/1.1")
    assertEquals("HTTP/1.1 405 Method Not Allowed\n", conn.messages[1])

    net.server:connect(conn)
    conn:receive("GET /api/system/1 HTTP/1.1")
    assertEquals("HTTP/1.1 405 Method Not Allowed\n", conn.messages[1])

    net.server:connect(conn)
    conn:receive("PATCH /api/system/1 HTTP/1.1")
    conn:receive("{\"entity\": {\"name\": \"Little Power\"}}")
    assertEquals("HTTP/1.1 405 Method Not Allowed\n", conn.messages[1])

    net.server:connect(conn)
    conn:receive("DELETE /api/system HTTP/1.1")
    assertEquals("HTTP/1.1 405 Method Not Allowed\n", conn.messages[1])
  end)

  test("Can create modes", function()
    net.server:connect(conn)
    conn:receive("PUT /api/modes HTTP/1.1")
    conn:receive("{\"entity\": {\"name\": \"helloWorld\", \"execute\": \"function() print(5) end\"}}")
    assertStartsWith("HTTP/1.1 200 OK", conn.messages[1])
  end)

  test("Selecting a mode executes said mode", function()
    net.server:connect(conn)
    conn:receive("GET /api/system/1000:selectedMode HTTP/1.1")
    assertStartsWith("HTTP/1.1 200 OK", conn.messages[1])
  end)
end)
