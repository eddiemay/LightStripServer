dofile("Bootstrap.lua")
dofile("TestingBootstrap.lua")
dofile("LightStripServer.lua")
local motorService = require "MotorService"

test("Motor API Server", function()
  local conn = MockConnection:new()

  test("Can set speed on motorService", function()
    local motor = motorService:update({entity = {speed = 100}, updateMask = {"speed"}})
    assertEquals(100, motor.speed)
  end)

  test("Can get motor via api server", function()
    net.server:connect(conn)
    conn:receive("GET /api/motors/1 HTTP/1.1")
    assertStartsWith("HTTP/1.1 200 OK", conn.messages[1])
  end)

  test("Can set speed via api server", function()
    net.server:connect(conn)
    conn:receive("PATCH /api/motors/1 HTTP/1.1")
    conn:receive("{\"entity\": {\"speed\": 200}, \"updateMask\": [\"speed\"]}")
    assertStartsWith("HTTP/1.1 200 OK", conn.messages[1])
    -- Can not do an exact match on the return string because the order of the properties is not consistant.
    assertContains("\"speed\":200", conn.messages[2])
  end)

  test("Can set speed via api server with data in first packet", function()
    net.server:connect(conn)
    local request =
        "PATCH /api/motors/1 HTTP/1.1\nHeader1: value\r\n\r\n{\"entity\":{\"speed\":250},\"updateMask\":[\"speed\"]}"
    conn:receive(request)
    assertStartsWith("HTTP/1.1 200 OK", conn.messages[1])
    -- Can not do an exact match on the return string because the order of the properties is not consistant.
    assertContains("\"speed\":250", conn.messages[2])
  end)

  test("Full HTTP PATCH request with all headers", function()
    local fullRequest = "PATCH /api/motors/1 HTTP/1.1\n" ..
        "Host: 192.168.4.1\n" ..
        "Connection: keep-alive\nContent-Length: 47\n" ..
        "Origin: http://192.168.4.1\n" ..
        "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) " ..
        "Chrome/72.0.3626.81 Safari/537.36\n" ..
        "Content-Type: text/plain;charset=UTF-8\n" ..
        "Accept: */*\n" ..
        "Referer: http://192.168.4.1/\n" ..
        "Accept-Encoding: gzip, deflate\n" ..
        "Accept-Language: en-US,en;q=0.9\r\n" ..
        "\r\n" ..
        "{\"entity\":{\"speed\":125},\"updateMask\":[\"speed\"]}"
    net.server:connect(conn)
    conn:receive(fullRequest)
    assertStartsWith("HTTP/1.1 200 OK", conn.messages[1])
    assertContains("\"speed\":125", conn.messages[2])
  end)
end)