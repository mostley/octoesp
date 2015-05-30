
local moduleName = ...
local M = {}
_G[moduleName] = M

local header = ''
local isTruncated = false

local function save(filename, response)
    if isTruncated then
        file.write(response)
        return
    end
    header = header..response
    local i, j = string.find(header, '\r\n\r\n')
    if i == nil or j == nil then
        return
    end
    prefixBody = string.sub(header, j+1, -1)
    file.write(prefixBody)
    header = ''
    isTruncated = true
    return
end

----
function M.updateFile(filename, url, callback)
    file.open(filename, 'w')
    local ip, port, path = string.gmatch(url, 'http://([0-9.]+):?([0-9]*)(/.*)')()
    if ip == nil then
        return false
    end
    if port == nil or port == '' then
        port = 80
    end
    port = port + 0
    if path == nil or path == '' then
        path = '/'
    end
    conn = net.createConnection(net.TCP, false)
    conn:on('receive', function(sck, response)
        save(filename, response)
    end)
    conn:on('disconnection', function(sck, response)
        local function reset()
            header = ''
            isTruncated = false
            file.close()
            tmr.stop(0)
            print(filename..' saved')
            compile(filename)
            callback()
        end
        tmr.alarm(0, 2000, 1, reset)
    end)
    conn:connect(port, ip)
    conn:send('GET '..path..' HTTP/1.0\r\nHost: '..ip..'\r\n'
    ..'Connection: close\r\nAccept: */*\r\n\r\n')
end

function M.update(callback)
    M.updateFile('init.lua', 'https://raw.githubusercontent.com/mostley/octoesp/master/source/udp_server/init.lua', callback)
    M.updateFile('connector.lua', 'https://raw.githubusercontent.com/mostley/octoesp/master/source/udp_server/connector.lua', callback)
    M.updateFile('upgrader.lua', 'https://raw.githubusercontent.com/mostley/octoesp/master/source/udp_server/upgrader.lua', callback)
    M.updateFile('server.lua', 'https://raw.githubusercontent.com/mostley/octoesp/master/source/udp_server/server.lua', callback)
end

