--[[ ��� ������ �� �������� Pears Project [ ���������� - Samp.Lua, Sampfuncs ] 
����� ���������� ��� ��� sha1, basexx --]]

-- ���������� � �������
script_name("Luna Helper")
script_author("cuzavr")
script_description("�������� ��� ���� �� Pears Project")
script_version("v0.4.2")

-- ���������
local encoding = require 'encoding'
encoding.default = 'CP1251'

-- ���������� � ������ �������
local sampevents = require 'lib.samp.events'
require 'sampfuncs'
local inicfg = require 'inicfg'
local vkeys = require 'vkeys'
local mainIni = inicfg.load({ -- ������ �������� � �������
    config = {
        password = 'nopassword', -- ������ �� �������� (��� ����������)
        google = 'nogoogle', -- 2FA �� �������� (��� ����������)

        login = 0, -- ���������, 0 - ����, 1 - ���
        autofuel = 0, -- ������������, 0 - ����, 1 - ���
        autosto = 0, -- ����������� � �����������, 0 - ����, 1 - ���
        autostoexit = 0, -- ��������� � ����������� ����� �����������, 0 - ����, 1 - ���
        lockvehicle = 0, -- ��� ������� �� L �������/������� ���������, 0 - ����, 1 - ���
        autostokolvo = 999 -- ��� ����������� � �����������, ���� ������� �� � ������ �� �����
    }
}, 'Luna Helper.ini')

-- ��� 2FA ����������
local sha1 = require('sha1')
local basexx = require('basexx')

-- ������
local clickedSTO = false -- ��� �����������
local noFuel = false -- ��� ������������

-- ������� � ����������� � ��������
local commands = {
    -- ��������
    ["/luna"] = { -- ���� �������
        action = function()
            lua_thread.create(function()
                -- ���������
                local autoLoginStatus = mainIni.config.login == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- ������������
                local autoFuelStatus = mainIni.config.autofuel == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- �����������
                local autoStoStatus = mainIni.config.autosto == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                local autostokolvoStatus = mainIni.config.autostokolvo
                local autoStoExitStatus = mainIni.config.autostoexit == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- �������/������� ��������� ��� ������� �� ������� L
                local lockvehicleStatus = mainIni.config.lockvehicle == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- ������ � ����
                local password = mainIni.config.password == 'nopassword' and "{FF0000}[�� ����������]" or "{00ff00}[����������]"
                local google = mainIni.config.google == 'nogoogle' and "{FF0000}[�� ����������]" or "{00ff00}[����������]"

                local dialogText = 
                "{cecece}������� �������\n" ..
                "{cd70ff}/luna {FFFFFF}- ���� �������.\n" ..
                "{cd70ff}/lunard {FFFFFF}- ������������� ������.\n" ..
                "{cd70ff}/lunabb {FFFFFF}- ��������� ������.\n" ..
                "{cd70ff}/lunacf {FFFFFF}- �������� ������ �������.\n" ..

                "\n{cd70ff}/lunalg {FFFFFF}- ��������/��������� ���������.\n" ..
                "{cd70ff}/lunaaf {FFFFFF}- ��������/��������� ������������.\n" ..
                "{cd70ff}/lunaas {FFFFFF}- ��������/��������� ����������� � �����������.\n" ..
                "{cd70ff}/lunaask {FFFFFF}- �������� ���-�� �� � �����������, ����� ��� ����� � ������ ��������.\n" ..
                "{cd70ff}/lunaaske {FFFFFF}- ��������/��������� ��������� ����� �����������.\n" ..

                "\n{cd70ff}/lunalock {FFFFFF}- ��������/��������� ������� ��������/�������� ���������� �� ������� {FF9000}[L]\n" ..

                "\n{cd70ff}/lunapass {FFFFFF}- �������� ������ ��� ����������.\n" ..
                "{cd70ff}/lunagoogle {FFFFFF}- �������� 2FA ��� ����������.\n" ..

                "{cecece}\n���� ���������\n" ..
                "{cd70ff}��������� " .. autoLoginStatus .. "\n" ..
                "{cd70ff}������������ " .. autoFuelStatus .. "\n" ..
                "{cd70ff}����������� � ����������� " .. autoStoStatus .. "\n" ..
                "{cd70ff}��������� � ����������� ����� ����������� " .. autoStoExitStatus .. "\n" ..
                "{cd70ff}��������/�������� ���������� ��� ������� �� ������� L " .. lockvehicleStatus .. "\n" ..

                "\n{cd70ff}������ " .. password .. "\n" ..
                "{cd70ff}2FA " .. google .. "\n" ..
                "{cd70ff}�� ��� ����������� � ����������� {FF9000}[" .. autostokolvoStatus .. "]\n"
                sampShowDialog(1, "{FF9000}Luna Helper v0.4.2", dialogText, "��", "", 0)
            end)
        end
    },
    ["/lunard"] = { -- ������������ �������
        action = function()
            lua_thread.create(function()
                thisScript():reload()
            end)
        end
    },
    ["/lunabb"] = { -- �������� �������
        action = function()
            lua_thread.create(function()
                sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}������ {FF0000}[��������]", 0xcececeFF)
                thisScript():unload()
            end)
        end
    },
    ["/lunacf"] = { -- ����� ������� (������� ������ � ���� �������� ������� � ������������ �������)
        action = function()
            lua_thread.create(function()
                os.remove(getWorkingDirectory().."\\config\\Luna Helper.ini")
                inicfg.load(mainIni, "..\\config\\Luna Helper.ini")
                thisScript():reload()
            end)
        end
    },
    -- ������ �������
    ["/lunalg"] = { -- ���������
        action = function()
            lua_thread.create(function()
                if mainIni.config.login == 0 then -- ���� ��������, �������� � ��������� ������
                    mainIni.config.login = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}��������� {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.login == 1 then -- ���� �������, ��������� � ��������� ������
                    mainIni.config.login =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}��������� {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    ["/lunaaf"] = { -- ������������
        action = function()
            lua_thread.create(function()
                if mainIni.config.autofuel == 0 then -- ���� ��������, �������� � ��������� ������
                    mainIni.config.autofuel = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}������������ {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.autofuel == 1 then -- ���� �������, ��������� � ��������� ������
                    mainIni.config.autofuel =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}������������ {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    -- ����������� � �����������
    ["/lunaas"] = { -- ��������/��������� �����������
        action = function()
            lua_thread.create(function()
                if mainIni.config.autosto == 0 then -- ���� ��������, �������� � ��������� ������
                    mainIni.config.autosto = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}����������� � ����������� {00ff00}[ON]", 0xcececeFF)
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}����������� �����������, ���� � ���������� ������ ��� ����� ��, ������� ������� � �������.", 0xcececeFF)
                elseif mainIni.config.autosto == 1 then -- ���� �������, ��������� � ��������� ������
                    mainIni.config.autosto = 0
                    mainIni.config.autostoexit = 0 -- ��������� ��� ������ �� �� ���
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}����������� � ����������� {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    ["/lunaaske"] = { -- ��������/��������� ��������� ����� �����������
        action = function()
            lua_thread.create(function()
                if mainIni.config.autostoexit == 0 then -- ���� ��������, �������� � ��������� ������
                    mainIni.config.autostoexit = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}��������� ����� ����������� {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.autostoexit == 1 then -- ���� �������, ��������� � ��������� ������
                    mainIni.config.autostoexit =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}��������� ����� ����������� {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    -- �����
    ["/lunalock"] = { -- ��� ������� �� L ����� ����������� �� ������ /lock
        action = function()
            lua_thread.create(function()
                if mainIni.config.lockvehicle == 0 then -- ���� ��������, �������� � ��������� ������
                    mainIni.config.lockvehicle = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}��������/�������� ���������� ��� ������� �� ������� L {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.lockvehicle == 1 then -- ���� �������, ��������� � ��������� ������
                    mainIni.config.lockvehicle =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}��������/�������� ���������� ��� ������� �� ������� L {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
}
-- �������
function main() -- �������� �������, ������������ ��� �������� �������
    while not isSampAvailable() do wait(0) end
    local ip, port = sampGetCurrentServerAddress()
    if ip ~= "185.169.132.133" and port ~= 7777 then -- Pears Project
        thisScript():unload() -- ��������� ������, ���� ���� ������� �� ������ ������
        return 0
    end
    if not doesFileExist("moonloader/config/Luna Helper.ini") then -- ���� ��� �������, ����� �� ����
        sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}�� ���������� ������ � ������ ���. ������ ��� ������� ������!", 0xcececeFF)
    end
    sampAddChatMessage("{00ff00}* {cd70ff}[Luna Helper] {FFFFFF}������ ������� {cecece}v0.4.2 {ffffff}������� ��������� {FF9000}[ /luna ]", 0xcececeFF)

    sampRegisterChatCommand("lunapass", lunapass_f) -- ������ �� ��������
    sampRegisterChatCommand("lunagoogle", lunagoogle_f) -- 2FA �� ��������
    sampRegisterChatCommand("lunaask", lunaask_f) -- �� ��� ����������� � �����������

    inicfg.save(mainIni, "Luna Helper.ini") -- ��� ������� ������� ��������� ������ (���� ��� �������, �� �������� � ����� ������)

    while true do
        wait(0)
        TextdrawSTO() -- ��������� ���
        AutoLock() -- �������� � �������� �� ��� ������� �� L
    end
end

function genCode(skey) -- ��������� ���� �� GAuth
    skey = basexx.from_base32(skey)
    value = math.floor(os.time() / 30)
    value = string.char(
        0, 0, 0, 0,
        bit.band(value, 0xFF000000) / 0x1000000,
        bit.band(value, 0xFF0000) / 0x10000,
        bit.band(value, 0xFF00) / 0x100,
        bit.band(value, 0xFF)) 
    local hash = sha1.hmac_binary(skey, value)
    local offset = bit.band(hash:sub(-1):byte(1, 1), 0xF)
    local function bytesToInt(a, b, c, d)
        return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
    end
    hash = bytesToInt(hash:byte(offset + 1, offset + 4))
    hash = bit.band(hash, 0x7FFFFFFF) % 1000000
    return ("%06d"):format(hash)
end

function lunapass_f(arg) -- ����� ������ �� �������� ��� ����������
    if arg == "" then -- ���� ������ �� ���� �������
        sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}�������� ������ �� ���������� {FF9000} [ /lunapass ������ ]", 0xcececeFF)
        return 0
    end

    mainIni.config.password = arg -- �������� ����� ������
    inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
    sampAddChatMessage("{00ff00}* {cd70ff}[Luna Helper] {FFFFFF}������ ������ �� {FF9000}"..arg, 0xcececeFF) -- ��������, ��� ������ �������
end

function lunagoogle_f(arg) -- ����� 2FA �� �������� ��� ����������
    if arg == "" then -- ���� ������ �� ���� �������
        sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}�������� ���� 2FA �� ���������� {FF9000} [ /lunapass ���� ]", 0xcececeFF)
        return 0
    end

    mainIni.config.google = arg -- �������� ����� 2FA
    inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
    sampAddChatMessage("{00ff00}* {cd70ff}[Luna Helper] {FFFFFF}���� �� 2FA ������ �� {FF9000}"..arg, 0xcececeFF) -- ��������, ��� 2FA �������
end

function lunaask_f(arg) -- ����� �� ��� ����������� � �����������
    if arg == "" then -- ���� ������ �� ���� �������
        sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}�������� �� ��� ����������� � ����������� {FF9000} [ /lunaask ���-�� ]", 0xcececeFF)
        return 0
    end

    local new_hp = tonumber(arg) -- ����������� arg � �����
    if not new_hp then -- �������� �� ������, ���� ���� ��� ����������
        sampAddChatMessage("{ff0000}* {cd70ff}[Luna Helper] {FFFFFF}������� �������� ��������!", 0xcececeFF)
        return 0
    end

    mainIni.config.autostokolvo = new_hp -- ��������� ��������������� ��������
    inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
    sampAddChatMessage("{00ff00}* {cd70ff}[Luna Helper] {FFFFFF}�� ����������� �������� �� {FF9000}"..new_hp, 0xcececeFF)
end


function sampevents.onSendCommand(command) -- ������� ��� ����� ��������� ������
    local parts = {}
    for part in command:gmatch("%S+") do
        parts[#parts + 1] = part
    end

    local cmd = parts[1] -- �������
    local playerId = parts[2] -- ID ������

    local cmdInfo = commands[cmd]
    if cmdInfo then
        cmdInfo.action(playerId)
        return false
    end
end

function sampevents.onShowDialog(id, style, title, button1, button2, text) -- �������
    -- ���������
    if id == 1290 or id == 1291 then 
        if mainIni.config.login == 1 and string.find(text, "����� ��������..") or string.find(text, "�������� ��������..") then 
            return false -- ������� ������ ����� � �������� ��������, ���� ��������� �������
        end
    end
    if id == 220 then
        if mainIni.config.login == 1 and string.find(text, "������,") then 
            sampSendDialogResponse(220, 1, 65535, "") -- �������� ����� � ������� ��� ����� ������ ����� �����
            return false -- ������� ������
        end
    end
    if id == 1 and mainIni.config.login == 1 and string.find(title, "�����������") then -- �������� ������ ���� ��������� �������
        if mainIni.config.password == 'nopassword' then
            return
        else
            sampSendDialogResponse(1, 1, 65535, mainIni.config.password)
            return false -- ������� ������
        end
    end
    if id == 798 and mainIni.config.login == 1 and string.find(title, "�����������") then -- �������� 2FA ���� ��������� �������
        if mainIni.config.google == 'nogoogle' then
            return
        else
            local code = genCode(mainIni.config.google) -- ��������� 2FA ����
            sampSendDialogResponse(798, 1, 65535, code) -- ����������� ��� � �����
            return false -- ������� ������
        end
    end

    -- ������������
    if id == 484 and mainIni.config.autofuel == 1 and string.find(title, "��������") then
        if noFuel == true then -- �� ������ ���������� ���� ����� ��� ��� ��� �����-�� ������, ����� �� ������� ������
            noFuel = false -- ����� ������ false ����� ���� ���������� �� ��������� ��
            return false
        end
        local liters = text:match("��� ������� ���� ��� ���������: (%d+) ������")
        if liters then -- ���� �������� ������������ ���-�� ������, ������� ����� ���������
            sampSendDialogResponse(484, 1, 65535, liters) -- ���������� �� ������������ ���-�� ������
            noFuel = true -- �� ������ ������ �������� ��� ����� ��� ��� ��� �����-�� ������
            return false -- ����� �� ������� ������, ����� �� ���������
        end
    end
    if id == 1700 and mainIni.config.autofuel == 1 and string.find(text, "� ���������") then
        noFuel = false -- ������� ��������, ���������� false
        return false -- ����� �� ������� ������, ����� �� ���������
    end

    -- ����������� � �����������
    if id == 562 and mainIni.config.autosto == 1 and string.find(title, "������������") then -- �����������
        if isCharInAnyCar(PLAYER_PED) then
            local autostokolvo = mainIni.config.autostokolvo -- �������� � ������� �� �������������
            local car = storeCarCharIsInNoSave(PLAYER_PED) -- �������� �� ��
            local health = getCarHealth(car) -- �������� �� ��
            
            if health <= autostokolvo then -- �������� ��, ���� � �� ������ ��� ����� �������� � ������� �����
                local responseID = 1 -- ���� ��� ������ ������, ��� ������ ���
                sampSendDialogResponse(562, responseID)  -- �������� ���
                ExitSTO() -- ������� ���������� � �����������
                return false
            end
        end
    end
    if id == 1700 and mainIni.config.autosto == 1 and string.find(text, "� ����������� �� ������� ��� ����������") then -- ���� ����� ����������� � ��� 
        sampAddChatMessage("{ff0000}* {cd70ff}[Luna Helper] {FFFFFF}����������� �� ���������. � ����������� ����������� ��� ���������.", 0xcececeFF)
        ExitSTO() -- ������� � ��� ���� �������� ������� ���������� � ��� ����� �����������
        return false -- ������� ������
    end
    if id == 1700 and mainIni.config.autosto == 1 and string.find(text, "��� �� ������� �����") then -- ���� ����� ��� �� �������
        sampAddChatMessage("{ff0000}* {cd70ff}[Luna Helper] {FFFFFF}����������� �� ���������. ��� �� ������� �����.", 0xcececeFF)
        ExitSTO() -- ������� � ��� ���� �������� ������� ���������� � ��� ����� �����������
        return false -- ������� ������
    end
    if id == 1700 and mainIni.config.autosto == 1 and string.find(text, "�� ������� �� �����������") then -- ���� �������
        return false
    end
end

function TextdrawSTO() -- ����������� ���������
    if mainIni.config.autosto == 1 then
        local buttonSTO = 13 -- �� ������
        local textSTO = 16 -- �� ������
        local autostokolvo = tonumber(mainIni.config.autostokolvo) -- �������� � ������� �� �������������

        if isCharInAnyCar(PLAYER_PED) then
            local car = storeCarCharIsInNoSave(PLAYER_PED) -- �������� �� ��
            local health = getCarHealth(car) -- �������� �� ��
            
            if health <= autostokolvo then -- �������� ��, ���� � �� ������ ��� ����� �������� � ������� �����
                if sampTextdrawIsExists(buttonSTO) 
                and sampTextdrawIsExists(textSTO) and sampTextdrawGetString(textSTO) == "O�c�y���a��e" -- �������� ������ (������������)
                and not clickedSTO then
                    sampSendClickTextdraw(buttonSTO) -- ������� �� ���������
                    clickedSTO = true -- ����� �� ������� �����
                elseif not sampTextdrawIsExists(buttonSTO) then
                    clickedSTO = false -- ����� � ���� ��� ������� �����
                end
            end
        end
    end
end

function ExitSTO() -- ��������� � �����������
    if mainIni.config.autostoexit == 1 then
        local buttonexit = 12 -- �� ������ ������ � �����������
        local textexit = 20 -- �� ������ ������ � �����������
        if sampTextdrawIsExists(buttonexit) and sampTextdrawIsExists(textexit) 
        and sampTextdrawGetString(textexit) == "��xo�" then -- �������� ������ (�����)
            sampSendClickTextdraw(buttonexit) -- ������� �� ���������
        end
    end
end

function AutoLock() -- ��������/�������� �� ����� L
    if mainIni.config.lockvehicle == 1 then
        if isKeyJustPressed(vkeys.VK_L) and not sampIsChatInputActive() 
        and not sampIsDialogActive() and not isSampfuncsConsoleActive() then -- �������� ����� �� ����������� ���� ��� ������ � ������
            sampSendChat("/lock")
        end
    end
end