
local moduleName = "Upgrader"
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
    local ip, port, path = string.gmatch(url, 'http[s]?://([^:/]*):?([0-9]*)(/.*)')()
    if ip == nil then
        print("invalid url")
        return false
    end
    if port == nil or port == '' then
        port = 80
    else
        port = tonumber(port)
    end
    if path == nil or path == '' then
        path = '/'
    end
    conn = net.createConnection(net.TCP, false)
    conn:on('receive', function(sck, response)
        print("receiving data")
        save(filename, response)
    end)
    conn:on('disconnection', function(sck, response)
        print("disconnect")
        local function reset()
            header = ''
            isTruncated = false
            file.close()
            tmr.stop(0)
            print(filename .. ' saved')
            node.compile(filename)
            callback()
        end
        tmr.alarm(0, 2000, 1, reset)
    end)
    print ("connecting with " .. ip)
    conn:connect(port, ip)
    html_msg = 'GET ' .. path .. ' HTTP/1.0\r\nHost: ' .. ip .. '\r\n' .. 'Connection: close\r\nAccept: */*\r\n\r\n'
    print ("sending html " .. html_msg)
    conn:send(html_msg)
end

function M.update(callback)
    print ("Downloading Connector...")
    M.updateFile('connector.lua', 'https://raw.githubusercontent.com/mostley/octoesp/master/source/udp_server/connector.lua', function()
        print ("...done")
        
        print ("Downloading Upgrader...")
        M.updateFile('upgrader.lua', 'https://raw.githubusercontent.com/mostley/octoesp/master/source/udp_server/upgrader.lua', function()
            print ("...done")

            print ("Downloading Server...")
            M.updateFile('server.lua', 'https://raw.githubusercontent.com/mostley/octoesp/master/source/udp_server/server.lua', function()
                print ("...done")

                print ("Downloading Init...")
                M.updateFile('init.lua', 'https://raw.githubusercontent.com/mostley/octoesp/master/source/udp_server/init.lua', function()
                    print ("...done")

                    callback()
                end)
            end)
        end)
    end)
end

