dofile("Bootstrap.lua")
dofile("TestingBootstrap.lua")
dofile("LightStripServer.lua")

name = "Eddie"
historyLoaded = false

test("Light Strip API Server", function()
  local conn = MockConnection:new()

  test("Loadstring", function()
    local code = "return \"Hello \" .. name";
    -- print(code)
    local sayHello = load(code)
    assertEquals("Hello Eddie", sayHello())
  end)

  test("Can create a mode", function()
    history = {
      name = "history",
      code = "historyLoaded = true\nonColorChange = function()\n" ..
          "  buffer:shift(1)\n  buffer:set(1, selectedColor)\n  ws2812.write(buffer)\nend\n"
    }
    -- print(history.code)

    net.server:connect(conn)
    conn:receive("POST /api/modes HTTP/1.1")
    conn:receive("{\"entity\": " .. sjson.encode(history) .. "}")
    assertStartsWith("HTTP/1.1 200 OK\n", conn.messages[1])
    assertEquals(1000, sjson.decode(conn.messages[2]).id)
  end)

  test("Can select a mode", function()
    assertEquals(false, historyLoaded)
    net.server:connect(conn)
    conn:receive("GET /api/modes/1000:setActive HTTP/1.1")
    assertStartsWith("HTTP/1.1 200 OK\n", conn.messages[1])
    assertEquals(true, historyLoaded)
  end)

  test("Changing the selected color with the history mode active invokes changing of the lights", function()
    net.server:connect(conn)
    conn:receive("GET /api/colors/1:setActive HTTP/1.1")
    assertStartsWith("HTTP/1.1 200 OK\n", conn.messages[1])
  end)
end)
