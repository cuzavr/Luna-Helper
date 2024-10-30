--[[ 
��� ������ �� �������� Pears Project [ ���������� - Samp.Lua ] 
���� ���� ������, �� ������ sampfuncs, ����� ���������� ��� ��� sha1, basexx
--]]

-- ���������� � �������
script_name("Luna Helper")
script_author("cuzavr")
script_description("�������� ��� ���� �� Pears Project")
script_version("v0.2")

-- ���������
local encoding = require 'encoding'
encoding.default = 'CP1251'

-- ���������� � ������
local sampevents = require 'lib.samp.events'
require 'sampfuncs'
local inicfg = require 'inicfg'
local mainIni = inicfg.load({
    config =
    {
        login = 0, -- ���������, 0 - ����, 1 - ���
        password = 'nopassword', -- ������ �� �������� (��� ����������)
        google = 'nogoogle', -- 2FA �� �������� (��� ����������)
        autofuel = 0 -- ������������, 0 - ����, 1 - ���
    } -- ������ ��������
}, 'Luna Helper.ini')

-- ��� 2FA
local sha1 = require('sha1')
local basexx = require('basexx')

-- ������� � ����������� � ��������
local commands = {
    -- ��������
    ["/luna"] = {
        action = function()
            lua_thread.create(function()
                local dialogText = 
                "{cccccc}��������\n" ..
                "{cd70ff}/luna {FFFFFF}- ������ ������ ������ �������.\n" ..
                "{cd70ff}/lunard {FFFFFF}- ������������� ������.\n" ..
                "{cd70ff}/lunabb {FFFFFF}- ��������� ������.\n" ..

                "{cccccc}\n������ �������\n" ..
                "{cd70ff}/lunalg {FFFFFF}- ��������/��������� ���������.\n" ..
                "{cd70ff}/lunaaf {FFFFFF}- ��������/��������� ������������.\n" ..
                "{cd70ff}/lunapass [������] {FFFFFF}- �������� ������ ��� ����������.\n" ..
                "{cd70ff}/lunagoogle [2FA] {FFFFFF}- �������� 2FA ��� ����������.\n"
                sampShowDialog(1, "{FF9000}Luna Helper", dialogText, "��", "", 0)
            end)
        end
    },
    ["/lunard"] = {
        action = function()
            lua_thread.create(function()
                thisScript():reload()
            end)
        end
    },
    ["/lunabb"] = {
        action = function()
            lua_thread.create(function()
                sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}������ {FF0000}[��������]", 0xccccccFF)
                thisScript():unload()
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
                    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}��������� {00ff00}[ON]", 0xccccccFF)
                elseif mainIni.config.login == 1 then -- ���� �������, ��������� � ��������� ������
                    mainIni.config.login =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}��������� {FF0000}[OFF]", 0xccccccFF)
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
                    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}������������ {00ff00}[ON]", 0xccccccFF)
                elseif mainIni.config.autofuel == 1 then -- ���� �������, ��������� � ��������� ������
                    mainIni.config.autofuel =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}������������ {FF0000}[OFF]", 0xccccccFF)
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
    if not doesFileExist("moonloader/config/Luna Helper.ini") then 
        sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}�� ���������� ������ � ������ ���. ������ ��� ������� ������!", 0xccccccFF)
    end
    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}������ ������� �������� {FF9000}[ /luna ]", 0xccccccFF)
    sampRegisterChatCommand("lunapass", lunapass_f) -- ������ �� ��������
    sampRegisterChatCommand("lunagoogle", lunagoogle_f) -- 2FA �� ��������
    inicfg.save(mainIni, "Luna Helper.ini") -- ��� ������� ������� ��������� ������ (���� ��� �������, �� �������� � ����� ������)

    while (true) and (is_pears) do
        wait(0)
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
        sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}�������� ������ �� ���������� {FF9000} [ /lunapass ������ ]", 0xccccccFF)
        return 0
    end

    mainIni.config.password = arg -- �������� ����� ������
    inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}������ ������ �� {FF9000}"..arg, 0xccccccFF) -- ��������, ��� ������ �������
end

function lunagoogle_f(arg) -- ����� 2FA �� �������� ��� ����������
    if arg == "" then -- ���� ������ �� ���� �������
        sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}�������� ���� 2FA �� ���������� {FF9000} [ /lunapass ���� ]", 0xccccccFF)
        return 0
    end

    mainIni.config.google = arg -- �������� ����� 2FA
    inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}���� �� 2FA ������ �� {FF9000}"..arg, 0xccccccFF) -- ��������, ��� 2FA �������
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
    if id == 1 and mainIni.config.login == 1 and string.find(title, "�����������") then -- �������� ������ ���� ��������� �������
        if mainIni.config.password == 'nopassword' then
            return
        else
            sampSendDialogResponse(id, 1, 65535, mainIni.config.password)
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
        local liters = text:match("��� ������� ���� ��� ���������: (%d+) ������")
        if liters then -- ���� �������� ������������ ���-�� ������, ������� ����� ���������
            sampSendDialogResponse(484, 1, 65535, liters) -- ���������� �� ������������ ���-�� ������
            return false -- ����� �� ������� ������, ����� �� ���������
        end
    end
end