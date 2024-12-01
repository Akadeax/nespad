local host, port = "127.0.0.1", 4065
local socket = require("socket.core")
local tcp = assert(socket.tcp())

local LUA_BINDING_CLOSE       = 2046
local LUA_BINDING_SEND_ADDR_0 = 2047

function writeCallback(address, value)
    local output = emu.read(0, emu.memType.cpuDebug)
    tcp:send("" .. output);
end

function endTests(address, value)
    emu.stop()
end

tcp:connect(host,port)

emu.addMemoryCallback(writeCallback, emu.memCallbackType.cpuWrite, LUA_BINDING_SEND_ADDR_0)
emu.addMemoryCallback(endTests, emu.memCallbackType.cpuWrite, LUA_BINDING_CLOSE)
