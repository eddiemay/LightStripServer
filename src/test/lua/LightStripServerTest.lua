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
    local sayHello = loadstring(code)
    assertEquals("Hello Eddie", sayHello())
  end)

  test("Sample modes should be included by default", function()
    net.server:connect(conn)
    conn:receive("GET /api/modes HTTP/1.1")
    assertStartsWith("HTTP/1.1 200 OK\n", conn.messages[1])
    local response = sjson.decode(conn.messages[2])
    assertEquals(3, response.totalSize)
    assertEquals("push", response.result[1].name)
    assertEquals("Chaser", response.result[2].name)
    assertEquals("Knight Rider", response.result[3].name)
  end)

  test("Can create a mode", function()
    history = {
      name = "history",
      code = "historyLoaded = true\nonColorChange = function()\n" ..
          "  buffer:shift(1)\n  buffer:set(1, selectedColor)\n  ws2812.write{pin = LED_PIN, data = buffer}\nend\n"
    }
    -- print(history.code)

    net.server:connect(conn)
    conn:receive("POST /api/modes HTTP/1.1")
    conn:receive("{\"entity\": " .. sjson.encode(history) .. "}")
    assertStartsWith("HTTP/1.1 200 OK\n", conn.messages[1])
    assertEquals(1003, sjson.decode(conn.messages[2]).id)
  end)

  test("Can select a mode", function()
    assertEquals(false, historyLoaded)
    net.server:connect(conn)
    conn:receive("GET /api/modes/1003:setActive HTTP/1.1")
    assertStartsWith("HTTP/1.1 200 OK\n", conn.messages[1])
    assertEquals(true, historyLoaded)
  end)

  test("Changing the selected color with the history mode active invokes changing of the lights", function()
    net.server:connect(conn)
    conn:receive("GET /api/colors:setActive?color=#00ee2b HTTP/1.1")
    assertStartsWith("HTTP/1.1 200 OK\n", conn.messages[1])
    assertEquals(string.char(43, 238, 0), selectedColor)
  end)
end)
