local APIServer = require "APIServer"
local APIService = require "GenericService"
local GenericStore = require "GenericStore"
local DAO = require "DAOFileIOImpl"
local resourceServlet = require "ResourceServlet"
local colors = require "colors"

local dao = DAO:new()
local colorStore = GenericStore:new{name = "color", dao = dao}
local colorService = APIService:new{store = colorStore}
local modeStore = GenericStore:new{name = "mode", dao = dao}
local modeService = APIService:new{store = modeStore}

ws2812.init()
local LEDS = 12
local buffer = ws2812.newBuffer(LEDS, 3)
local timer = tmr.create();

local onColorChange

local reset = function()
  timer:unregister()
  onColorChange = nil
  buffer:fill(0, 0, 0)
  ws2812.write(buffer)
  return {}
end

local selectedColors = {colors.blue}

local systemService = {
  selectedColor = function(self, request)
    selectedColor[request.id] = colorStore:get(request.entity.color)
    if (onColorChange) then
      onColorChange(request.id)
    end
    return {}
  end,
  selectedMode = function(self, request)
    local mode = modeStore:get(request.id)
    if (mode) then
      reset()
      mode.execute()
    end
    return {}
  end,
  chaser = function(self, request)
    reset()
    local i = 0
    timer:register(50, tmr.ALARM_AUTO, function()
      buffer:fade(2)
      buffer:set(i + 1, color)
      ws2812.write(buffer)
      i = (i + 1) % LEDS
    end)
    timer:start()
    return {}
  end,
  knightRider = function(self, request)
    reset()
    local i = 0
    local upperLimit = LEDS * 2
    timer:register(50, tmr.ALARM_AUTO, function()
      buffer:fade(2)
      local index = i
      if (index >= LEDS) then
        index = LEDS - (i % LEDS) - 1
      end
      buffer:set(index + 1, color)
      ws2812.write(buffer)
      i = (i + 1) % upperLimit
    end)
    timer:start()
    return {}
  end,
  history = function(self, request)
    reset()
    self.onColorChange = function(index)
      buffer:shift(1)
      buffer:set(1, selectedColors[index])
      ws2812.write(buffer)
      return request.entity
    end
    return {}
  end,
  reset = function(self, request)
    reset()
  end,
}

systemService:reset()

local server = APIServer:new{resourceServlet = resourceServlet,
  services = {colors = colorService, modes = modeService, system = systemService}}
server:start()
