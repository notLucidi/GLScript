--// Growlauncher Script
--// Script By Lucius
--// WORLD FINDER
--// SUBSCRIBE SVE GTPS

mode = "nn" --// NN : No Number | WN : With Number | NO : Number Only
length = 5
prefix = ""
suffix = ""
console_prefix = "`b[`9L`wuciu`9S`b]`9 "

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
          "default": "]] ..
    prefix ..
        [[",
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
          "default": "]] ..
            suffix ..
                [[",
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
          "default": "]] ..
                    mode ..
                        [[",
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
          "default": "]] ..
                            length ..
                                [[",
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
    log(console_prefix .. message)
end

function overlay(message)
    growtopia.notify("`4[`9L`wuciu`9S`4]`9 " .. message)
end

function saveLogs(data)
    file = io.open("/storage/emulated/0/Android/data/launcher.powerkuy.growlauncher/ScriptLua/LogGenerate.db", "a")
    if file then
        file:write(data)
        file:close()
    end
end

function generateWorld()
    local chars = ""
    local world = ""

    if mode:find("wn") then
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    elseif mode:find("nn") then
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    elseif mode:find("no") then
        chars = "1234567890"
    end

    for i = 1, length do
        local gRan = math.random(1, #chars)
        world = world .. string.sub(chars, gRan, gRan)
    end

    world = prefix .. world .. suffix
    data = "[+] | " .. os.date("!%a %b %d, %H:%M", os.time() + 7 * 60 * 60) .. " | Generate > " .. world .. " [+]\n"
    saveLogs(data)

    console("Entering World : `2" .. world)
    sendPacket(3, "action|join_request\nname|" .. world .. "\ninvitedWorld|0")
end

function formater(id, count)
    local itemName = growtopia.getItemName(id) or "Unknown"
    return string.format("add_button_with_icon|info_%d|%d|frame|%d|%d|\n", id, count, id, count)
end

function scannedResult()
    local items = ""
    local totalItems = 0

    for itemid, count in pairs(setDefault) do
        if count > 0 then
            items = items .. formater(itemid, count)
            totalItems = totalItems + 1
        end
    end

    local baseDialog =
        [[
add_label_with_icon|big|`bScan Result``|left|7188|
add_smalltext|Script by `6@SveGTPS`4 x `6@Lucius``|
add_spacer|small|
add_smalltext|`oResults Found: `w]] ..totalItems ..[[ `oitems|left|
add_spacer|small|
end_dialog|req|Cancel|| 
add_spacer|big|]] .. items .. [[
add_quick_exit|
]]
    sendVariant({v1 = "OnDialogRequest", v2 = baseDialog})
end

function scanTiles()
    local tiles = getTiles()

    for _, tile in ipairs(tiles) do
        local id = tile.fg
        if setDefault[id] ~= nil then
            setDefault[id] = setDefault[id] + 1
        end
    end

    scannedResult()
end

function onValue(t, n, v)
    if t == 1 then
        if n == "config_length" then
            length = v
        end
    end
    if t == 5 then
        if n == "config_prefix" then
            prefix = v
        end

        if n == "config_suffix" then
            suffix = v
        end

        if n == "config_mode" then
            mode = v
        end
    end
    if t == 0 then
        if n == "button_generate" then
            local time = os.time()
            local cooldown = 5
            local executed = 0

            if time - lastExecuted >= cooldown then
                generateWorld()
                lastExecuted = time
            else
                local remainingTime = cooldown - (currentTime - lastExecuted)
                console("Cooldown: " .. remainingTime .. " sec left.")
            end
        end

        if n == "button_scan" then
            scanTiles()
        end
    end
end

applyHook()
