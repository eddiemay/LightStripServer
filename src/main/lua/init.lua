wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ ssid = "HDMI-MATRIX", pwd = "12345678" })
--wifi.sta.config("Mayfield-Wifi", "mayfield")
dofile("Bootstrap.lua")
dofile("LightStripServer.lua")
