
local staticModes = {
  history = function()
    onColorChange = function(index)
      buffer:shift(1)
      buffer:set(1, selectedColors[index])
      ws2812.write(buffer)
    end
  end,
  chaser = function()
    local i = 0
    timer:register(50, tmr.ALARM_AUTO, function()
      buffer:fade(2)
      buffer:set(i + 1, color)
      ws2812.write(buffer)
      i = (i + 1) % LEDS
    end)
    timer:start()
  end,
  knightRider = function()
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
  end,
}