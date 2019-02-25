local APIServer = require "APIServer"
local APIService = require "GenericService"
local GenericStore = require "GenericStore"
local DAO = require "DAOFileIOImpl"
local resourceServlet = require "ResourceServlet"
local motorService = require "MotorService"

local toColor = function(rgb)
  local r = tonumber(string.sub(rgb, 2, 3), 16)
  local g = tonumber(string.sub(rgb, 4, 5), 16)
  local b = tonumber(string.sub(rgb, 6, 7),16)
  return {rgb = rgb, ws2812Color = string.char(b, g, r)}
end

LEDS = 12
LED_PIN = 23
buffer = ws2812.newBuffer(LEDS, 3)
timer = tmr.create()
selectedColor = toColor("#0000ff")
onColorChange = nil

local selectedMode
local selectedModeCode

local reset = function()
  timer:unregister()
  selectedMode = nil
  onColorChange = nil
  buffer:fill(0, 0, 0)
  ws2812.write{pin = LED_PIN, data = buffer}
end

local dao = DAO:new()
local colorStore = GenericStore:new{name = "color", dao = dao}
local colorService = APIService:new{
  store = colorStore,
  setActive = function(self, request)
    local color
    if (request.color) then
      color = toColor(request.color)
    else
      color = self.store:get(request.id)
    end
    if (color == nil) then
      return {_errorCode = 404, _message = "Unknown color"}
    end
    selectedColor = color.ws2812Color
    if (onColorChange) then
      onColorChange()
    end
    return {}
  end,
}
local modeStore = GenericStore:new{name = "mode", dao = dao}
local modeService = APIService:new{
  store = modeStore,
  setActive = function(self, request)
    local mode = self.store:get(request.id)
    if (mode == nil) then
      return {_errorCode = 404, _message = "Unknown mode: " .. request.id}
    end
    if (mode.code == nil) then
      return {_errorCode = 502, _message = "Selected mode has no code."}
    end
    reset()
    selectedMode = mode
    selectedModeCode = loadstring(mode.code)
    selectedModeCode()
    return {}
  end,
  reset = function(self)
    reset()
    return {}
  end
}

-- If we don't have any modes, create samples.
if (modeStore:list().totalSize == 0) then
  modeStore:create{
    name = "push",
    code = "onColorChange = function()\n" ..
        "  buffer:shift(1)\n  buffer:set(1, selectedColor)\n  ws2812.write{pin = LED_PIN, data = buffer}\nend\n"
  }
  modeStore:create{
    name = "Chaser",
    code = "local i = 0\ntimer:register(50, tmr.ALARM_AUTO, function()\n" ..
        "  buffer:fade(2)\n  buffer:set(i + 1, selectedColor)\n  ws2812.write{pin = LED_PIN, data = buffer}\n" ..
        "  i = (i + 1) % LEDS\nend)\ntimer:start()\n"
  }
  modeStore:create{
    name = "Knight Rider",
    code = "local i = 0\nlocal upperLimit = LEDS * 2\ntimer:register(50, tmr.ALARM_AUTO, function()\n" ..
        "  buffer:fade(2)\n  local index = i\n  if (index >= LEDS) then\n    index = LEDS - (i % LEDS) - 1\n  end\n" ..
        "  buffer:set(index + 1, selectedColor)\n  ws2812.write{pin = LED_PIN, data = buffer}\n" ..
        "  i = (i + 1) % upperLimit\nend)\ntimer:start()\n"
  }
end

local server = APIServer:new{resourceServlet = resourceServlet,
  services = {colors = colorService, modes = modeService, motors = motorService}}
server:start()
