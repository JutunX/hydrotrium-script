fgems = {}
profitGems = 0

for i,bot in pairs(getBots()) do
    fgems[bot.name] = bot.gems
end

function checkBot()
    botArray = {}
    for i, bot in pairs(getBots()) do
        local gems = bot.gems
        local world = bot.world:upper()

        botArray[#botArray + 1] = {
            botIndex = "[" .. i .. "] ",
            name = bot.name,
            status = bot.status,
            level = bot.level,
            gems = gems,
            world = world
        }

        if (gems - fgems[bot.name]) > 0 then
            profitGems = profitGems + (gems - fgems[bot.name])
        end

        fgems[bot.name] = gems
    end
end


function formatNumber(count)
    local number = count
    local formattedNumber
    if number >= 1000 then
        formattedNumber = string.format("%.3f", number / 1000):gsub("%.", ",")
    else
        formattedNumber = tostring(number)
    end
    return formattedNumber
end

function status(num)
    if num:upper() ~= "ONLINE"  then
        return "<a:OFFLINE:1142826338307280997> " 
    else
        return "<a:online2:1174926338164002818> "
    end
end

function censorHalfWithStars(inputString)
    local length = #inputString
    local censorLength = math.ceil(length / 2)
    
    local resultString = inputString:sub(1, length - censorLength)
    resultString = resultString .. string.rep('#', censorLength)
    
    return resultString
end

function botInfo()
    local fieldArray = {}
    for _, botInfo in ipairs(botArray) do
        fieldArray[#fieldArray + 1] = [==[
            @{
                name = "]==]..botInfo.botIndex..censorHalfWithStars(botInfo.name)..[==["
                value = "Status : ]==]..status(botInfo.status)..botInfo.status.."\n"..[==[ Level : ]==]..botInfo.level.."\n"..[==[ Gems : ]==]..formatNumber(botInfo.gems).."\n"..[==[ Farming at : ||]==]..botInfo.world..[==[||"
                inline = "true"
            }
        ]==]
    end

    local text = [[
        $webHookUrl = "]]..webhookLink..[[/messages/]]..messageId..[["
        $CPU = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select -ExpandProperty Average
        $CompObject =  Get-WmiObject -Class WIN32_OperatingSystem
        $Memory = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory)*100)/ $CompObject.TotalVisibleMemorySize)
        $RAM = [math]::Round($Memory, 0)
        $thumbnailObject = @{
            url = ""
        }
        $footerObject = @{
            text = "View All Bot V1.1 by Jutun Script]].."\n"..(os.date("!%a %b %d, %Y at %I:%M %p", os.time() + 7 * 60 * 60))..[["
        }
        $fieldArray = @(
            @{
                name = ""
                value = "**Total Profit From All Bots : ]]..formatNumber(profitGems)..[[ Gems]].."\n"..[[CPU : $CPU% ]].."\n"..[[RAM : $RAM%]].."\n"..[[Next refresh <t:]] .. os.time() + refreshTime .. [[:R>**"
                inline = "false"
            }
            ]]..table.concat(fieldArray, ',\n')..[[
        )
        $embedObject = @{
            title = "**<:hydro:1169832126540173322> Bots Info by Jutun [https://discord.gg/kz8RNDWD9N]**"
            color = "]]..math.random(111111,999999)..[["
            thumbnail = $thumbnailObject
            footer = $footerObject
            fields = $fieldArray
        }
        $embedArray = @($embedObject)
        $payload = @{
            embeds = $embedArray
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'
    ]]
    
    local file = io.popen("powershell -command -", "w")
    file:write(text)
    file:close()
end

while true do
    checkBot()
    sleep(100)
    botInfo()
    sleep(refreshTime * 1000)
end
