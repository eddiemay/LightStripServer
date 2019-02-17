local APIServer = require "APIServer"
local APIService = require "GenericService"
local GenericStore = require "GenericStore"
local DAO = require "DAOFileIOImpl"
local resourceServlet = require "ResourceServlet"
local colors = require "colors"
local motorService = require "MotorService"

ws2812.init()
LEDS = 12
buffer = ws2812.newBuffer(LEDS, 3)
timer = tmr.create()
selectedColor = colors.blue
onColorChange = nil

local selectedMode
local selectedModeCode

local reset = function()
  timer:unregister()
  selectedMode = nil
  onColorChange = nil
  buffer:fill(0, 0, 0)
  ws2812.write(buffer)
end

local dao = DAO:new()
local colorStore = GenericStore:new{name = "color", dao = dao}
local colorService = APIService:new{
  store = colorStore,
  setActive = function(self, request)
    local color
    if (request.entity and request.entity.color) then
      color = self.store:get(request.entity.color)
    else
      color = self.store:get(request.id)
    end
    if (color == nil) then
      return {_errorCode = 404, _message = "Unknown color"}
    end
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
    selectedModeCode = load(mode.code)
    selectedModeCode()
    return {}
  end,
  reset = function(self)
    reset()
  end
}

local server = APIServer:new{resourceServlet = resourceServlet,
  services = {colors = colorService, modes = modeService, motors = motorService}}
server:start()
