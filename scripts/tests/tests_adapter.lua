local host, port = "127.0.0.1", 4065
local socket = require("socket.core")
local tcp = assert(socket.tcp())

local LUA_BINDING_SEND_ADDR_0 = 2047

function writeCallback(address, value)
    local output = emu.read(0, emu.memType.cpuDebug)

    if output == 255 then
        emu.stop()
        return
    end

    tcp:send("" .. output);
end


tcp:connect(host,port)

emu.addMemoryCallback(writeCallback, emu.memCallbackType.cpuWrite, LUA_BINDING_SEND_ADDR_0)
