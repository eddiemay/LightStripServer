local DIRECTION = {
  CLOCK_WISE = -1,
  COUNTER_CLOSE_WISE = 1
}
local motorPinStates = {{0, 0, 0, 1}, {0, 0, 1, 1}, {0, 0, 1, 0}, {0, 1, 1, 0}, {0, 1, 0, 0}, {1, 1, 0, 0}, {1, 0, 0, 0}, {1, 0, 0, 0}}
local motorTimer = tmr.create();
local motor = {pins = {0, 1, 2, 3}, speed = 500, direction = DIRECTION.COUNTER_CLOSE_WISE}

local writeMotor = function(motorState)
  local motorPinState = motorPinStates[motorState + 1]
  local motorPins = motor.pins
  for i = 1, #motorPins do
    gpio.write(motorPins[i], motorPinState[i])
  end
end

return {
  get = function(self, request)
    return motor
  end,
  update = function(self, request)
    local updateMask = request.updateMask
    for i = 1, #updateMask do
      motor[updateMask[i]] = request.entity[updateMask[i]]
    end
    return motor
  end,
  start = function(self, request)
    local motorState = 0;
    local motorPins = motor.pins
    for i = 1, #motorPins do
      gpio.mode(motorPins[i], gpio.OUTPUT)
    end
    motorTimer:register(1000 / motor.speed, tmr.ALARM_AUTO, function()
      writeMotor(motorState)
      motorState = (motorState + motor.direction) % #motorPinStates
    end)
    motorTimer:start()
    return {}
  end,
  stop = function(self, request)
    motorTimer:unregister()
    local motorPins = motor.pins
    for i = 1, #motorPins do
      gpio.write(motorPins[i], 0)
    end
    return {}
  end
}
