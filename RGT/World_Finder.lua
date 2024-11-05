--// Growlauncher Script
--// Script By Lucius
--// WORLD FINDER
--// SUBSCRIBE SVE GTPS

config = {
    mode = "nn",
    length = 5,
    prefix = "",
    suffix = "",
    console_prefix = "`b[`9L`wuciu`9S`b]`9 ",
    targetIDs = {3918, 202, 242, 206, 204},
    requiredItems = {}
}

Lucid =
    [[
    {
      "sub_name": "World Finder",
      "icon": "Public",
      "menu": [
        {
          "type": "labelapp",
          "icon": "Settings",
          "text": "World Finder - V1"
        },
        {
          "type": "divider"
        },
        {
          "type": "dialog",
          "text": "Customize",
          "support_text": "Settings World Finder Here",
          "fill": true,
          "menu": [
            {
              "type": "labelapp",
              "text": "Customize World Finder",
              "icon": "Public"
            },
            {
              "type": "label",
              "text": "Script by Lucius x SveGTPS"
            },
            {
              "type": "divider"
            },
            {
              "type": "input_string",
              "text": "Set Prefix",
              "default": "]] .. prefix .. [[",
              "placeholder": "Example: STORAGE",
              "icon": "Edit",
              "alias": "config_prefix"
            },
            {
              "type": "tooltip",
              "icon": "tips_icon",
              "text": "Hint :",
              "support_text": "More Example: prefix + world name, output : STORAGEVED"
            },
            {
              "type": "divider"
            },
            {
              "type": "input_string",
              "text": "Set Suffix",
              "default": "]] .. suffix .. [[",
              "placeholder": "Example: FARM",
              "icon": "Edit",
              "alias": "config_suffix"
            },
            {
              "type": "tooltip",
              "icon": "tips_icon",
              "text": "Hint :",
              "support_text": "More Example: world name + suffix, output : DKOFARM"
            },
            {
              "type": "divider"
            },
            {
              "type": "input_string",
              "text": "Set Prefix",
              "default": "]] .. mode .. [[",
              "placeholder": "Example: NN",
              "icon": "Edit",
              "alias": "config_mode"
            },
            {
              "type": "tooltip",
              "icon": "tips_icon",
              "text": "Hint :",
              "support_text": "No Number (NN) | With Number (WN) | Number Only (NO)"
            },
            {
              "type": "divider"
            },
            {
              "text": "Length",
              "type": "slider",
              "default": "]] .. length .. [[",
              "min": 1,
              "max": 24,
              "alias": "config_length"
            },
            {
              "type": "tooltip",
              "icon": "tips_icon",
              "text": "Hint :",
              "support_text": "Set Length to generate 1 or more up to 24 letters."
            },
            {
              "type": "divider"
            },
            {
              "type": "labelapp",
              "text": "Lucius",
              "icon": "Handyman"
            },
            {
              "type": "divider"
            }
          ]
        },
        {
          "type": "divider"
        },
        {
          "type": "button",
          "text": "Generate",
          "alias": "button_generate"
        },
        {
          "type": "button",
          "text": "Scan",
          "alias": "button_scan"
        }
      ]
    }
]]
addIntoModule(Lucid)

function console(message)
    log(config.console_prefix .. message)
end

function overlay(message)
    growtopia.notify("`4[`9L`wuciu`9S`4]`9 " .. message)
end

function saveLogs(data)
    file = io.open("/storage/emulated/0/Android/data/launcher.powerkuy.growlauncher/ScriptLua/LogGenerate.db", "w") 
    if file then
        file:write(data)
        file:close()
    end
end

function saveConfig()
    local file = io.open("/storage/emulated/0/Android/data/launcher.powerkuy.growlauncher/ScriptLua/configs.c", "w")
    if file then
        for key, value in pairs(config) do
            if type(value) == "table" then
                file:write(key .. "=" .. table.concat(value, ",") .. "\n")
            else
                file:write(key .. "=" .. tostring(value) .. "\n")
            end
        end
        file:close()
        console("Config saved!")
    else
        console("`4Failed to save config!")
    end
end

function loadConfig()
    local file = io.open("/storage/emulated/0/Android/data/launcher.powerkuy.growlauncher/ScriptLua/configs.c", "r")
    if file then
        for line in file:lines() do
            local key, value = line:match("([^=]+)=([^=]*)")
            if key and value then
                if value:find(",") then
                    local items = {}
                    for item in value:gmatch("[^,]+") do
                        table.insert(items, tonumber(item) or item)
                    end
                    config[key] = items
                else
                    if value == "true" then
                        config[key] = true
                    elseif value == "false" then
                        config[key] = false
                    else
                        config[key] = tonumber(value) or value
                    end
                end
            end
        end
        file:close()
        console("Config Loaded!")
    else
        print("`4Failed to load config!")
    end
end

function generateWorld()
    local chars = ""
    local world = ""

    if config.mode:find("wn") then
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    elseif config.mode:find("nn") then
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    elseif config.mode:find("no") then
        chars = "1234567890"
    end

    for i = 1, config.length do
        local gRan = math.random(1, #chars)
        world = world .. string.sub(chars, gRan, gRan)
    end

    world = config.prefix .. world .. config.suffix
    data = "[+] | " .. os.date("%a %b %d, %H:%M", os.time()) .. " | Generate > " .. world .. " [+]\n"
    saveLogs(data)

    console("Entering World : `2" .. world)
    sendPacket(3, "action|join_request\nname|" .. world .. "\ninvitedWorld|0")
end

function generateItems(id, count)
    local itemName = growtopia.getItemName(id) or "Unknown"
    return string.format("add_button_with_icon|info_%d|`4%s : %d |frame|%d|%d|\n", id, itemName, count, id, count)
end

function displayRequiredItemsDialog()
    local items = ""
    local totalItems = 0
    
    for itemid, count in pairs(config.requiredItems) do
        if count > 0 then
            items = items .. generateItems(itemid, count)
            totalItems = totalItems + 1
        end
    end

    local baseDialog = [[
add_label_with_icon|big|`bScanned Result``|left|7188|
add_smalltext|Script by `6@SveGTPS`4 x `6@Lucius``|
add_spacer|small|
add_smalltext|`oResults Found: `w]] .. totalItems .. [[ `oitems|left|
add_spacer|small|
end_dialog|req|Cancel|| 
add_spacer|big|
]] .. items .. [[
add_quick_exit|
]]
    sendVariant({v1 = "OnDialogRequest", v2 = baseDialog})
end

function scanTiles()
    local tiles = getTiles()
    
    for _, id in ipairs(config.targetIDs) do
        config.requiredItems[id] = 0
    end
    
    for _, tile in ipairs(tiles) do
        local id = tile.fg
        if config.requiredItems[id] ~= nil then
            config.requiredItems[id] = config.requiredItems[id] + 1
        end
    end

    displayRequiredItemsDialog()
end

function onValue(t, n, v)
    if t == 1 then
        if n == "config_length" then
            config.length = v
        end
    end
    if t == 5 then
        if n == "config_prefix" then
            config.prefix = v
        end

        if n == "config_suffix" then
            config.suffix = v
        end

        if n == "config_mode" then
            if v == "nn" or v == "wn" or v == "no" then
                config.mode = v
            else
                console("Invalid mode! Please use 'nn', 'wn', or 'no'.")
            end
        end
    end
    
    if t == 0 then
        if n == "button_generate" then
            generateWorld()
        end

        if n == "button_scan" then
            scanTiles() 
        end
    end
end

loadConfig()
applyHook()
