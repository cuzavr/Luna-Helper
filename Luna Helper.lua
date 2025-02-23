--[[ ��� ������ �� �������� Pears Project [ ���������� - Samp.Lua, Sampfuncs, Moon Imgui ] 
����� ���������� ��� ��� sha1, basexx --]]

-- ���������� � �������
script_name("Luna Helper")
script_author("cuzavr")
script_description("�������� ��� ���� �� Pears Project")
script_version("v0.5.2")

-- ����������
local encoding = require 'encoding' -- ���������
encoding.default = 'CP1251' -- ���������
local sampevents = require 'lib.samp.events' -- ��� ��������� ������� ����� (������� � �������)
require 'sampfuncs' -- Sampfuncs
local vkeys = require 'vkeys' -- ��� ��������� ������ � �� ����������
local sha1 = require 'sha1' -- ��� 2FA
local basexx = require 'basexx' -- ��� 2FA
local imgui = require 'imgui' -- ��� ���������� �������

-- ������ �������
local inicfg = require 'inicfg'
local mainIni = inicfg.load({ -- ������ �������� � �������
    config = {
        -- ��������
        password = 'nopassword', -- ������ �� �������� (��� ����������)
        google = 'nogoogle', -- 2FA �� �������� (��� ����������)

        -- �������������� �������. false - ����, true - ���
        login = false, -- ���������
        autofuel = false, -- ������������
        autosto = false, -- ����������� � �����������
        autostoexit = false, -- ��������� � ����������� ����� �����������
        lockvehicle = false, -- ��� ������� �� lockvehicle_key �������/������� ���������
        lockvehicle_key = vkeys.VK_L,

        -- ������
        autostokolvo = 999 -- ��� ����������� � �����������, ���� ������� �� � ������ �� �����
    }
}, 'Luna Helper.ini')

-- ������
local lunaversion = "v0.5.2" -- ������ ������� ��� �������� � ��
local clickedSTO = false -- ��� �����������
local noFuel = false -- ��� ������������

-- ���������� (imgui)
u8 = encoding.UTF8 -- ����� imgui ������������ ������� ������� (������� ���: u8"[������������_�����]")
show_main_window = imgui.ImBool(false) -- �����\������� ����
local autoLogin_imgui = imgui.ImBool(mainIni.config.login) -- CheckBox (����� CB - ��������� � ��������) ��� ����������
local lockPlayer_imgui = imgui.ImBool(mainIni.config.lockvehicle) -- CB ��� ������ ��������\�������� ������
local autoFuel_imgui = imgui.ImBool(mainIni.config.autofuel) -- CB ��� ������������
local autoSTO_imgui = imgui.ImBool(mainIni.config.autosto) -- CB ��� �������������� ������� �� ���
local autoSTOExit_imgui = imgui.ImBool(mainIni.config.autostoexit) -- CB ��� ��������������� ������ � ��� ����� �������
local autoSTOKolvo_imgui = imgui.ImInt(mainIni.config.autostokolvo) -- ������ � �������� �������� ������������ ���������� �� ��� ������� ����
local pass_buffer_imgui = imgui.ImBuffer(256) -- ������ ��� �������� ������
pass_buffer_imgui.v = tostring(mainIni.config.password) -- ��������� ������ ������� �� �������
local google_buffer_imgui = imgui.ImBuffer(256) -- ������ ��� 2FA
google_buffer_imgui.v = tostring(mainIni.config.google) -- ��������� ������ 2FA �� �������
local pass_show_imgui = imgui.ImBool(false) -- CB ���������� �� ������ (�� ��������� ������ ������ ���������� (*))
local pass_show = false -- ������������ � ������������ � pass_show_imgui
local google_show_imgui = imgui.ImBool(false) -- CB ���������� �� 2FA (�� ��������� 2FA ������ ���������� (*))
local google_show = false -- ������������ � ������������ � google_show_imgui
local isChangingButton = false -- ���� ����� ������ ������ ��������\�������� ��, �� ������ ������ ��� �������� � "�������� ������" �� "���������� ������� ��������� ������"

-- ������� � ����������� � ��������
local commands = {
    -- ��������
    ["/luna"] = { -- ���� �������
        action = function()
            lua_thread.create(function()
                show_main_window.v = not show_main_window.v
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
                sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}������ {FF0000}[��������]", 0xccccccAA)
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
}
-- �������
function main() -- �������� �������, ������������ ��� �������� �������
    while not isSampAvailable() do wait(0) end
    local ip = sampGetCurrentServerAddress()
    if ip ~= "5.252.35.11" then -- Pears Project
        thisScript():unload() -- ��������� ������, ���� ���� ������� �� ������ ������
        return 0
    end
    if not doesFileExist("moonloader/config/Luna Helper.ini") then -- ���� ��� �������, ����� �� ����
        sampAddChatMessage("{00ff00}* {cd70ff}[Luna Helper] {FFFFFF}�� ���������� ������ � ������ ���. ������ ��� ������� ������!", 0xccccccAA)
    end
    sampAddChatMessage("{00ff00}* {cd70ff}[Luna Helper] {FFFFFF}������ ������� {cccccc}" .. lunaversion .. " {ffffff}������� ��������� {FF9000}[ /luna ]", 0xccccccAA)
    inicfg.save(mainIni, "Luna Helper.ini") -- ��� ������� ������� ��������� ������ (���� ��� �������, �� �������� � ����� ������)

    while true do
        wait(0) -- ��� � 0 ��� ������� ���� ����������, �� ���� �� ��
        imgui.Process = show_main_window.v
        if show_main_window.v == false then
            pass_show, pass_show_imgui.v, google_show, google_show_imgui.v = false, false, false, false
        end
        pass_buffer_imgui.v = tostring(mainIni.config.password)
        google_buffer_imgui.v = tostring(mainIni.config.google)
        autoSTOKolvo_imgui.v = mainIni.config.autostokolvo
        TextdrawSTO() -- ��������� ���
        AutoLock() -- �������� � �������� �� ��� ������� �� L
    end
end

function pressNewButton() -- "����� ����� ��������". �������, ������� ������������� ����� ������� ��� ��������\�������� ��.
    local buff = true
    while buff do -- ��������� ������ ������ vkeys, ��� ����������� ����� ������� ������
        wait(0) -- ��� ����
        if not buff then -- ������ � ��, �� ��� ���� ����� �� �� ����� ����������� �������, � ������ ��� � ���� ��������
            break
        else
            for i, value in pairs(vkeys) do -- ������ ������ � ��������
                if isKeyJustPressed(value) then -- ���� ������ ���� ������, �� ��������� � � ������� + ��������� � ����. �������� �� ��� ������, ��� ��� ������� � ���� ����.
                    mainIni.config.lockvehicle_key = value
                    SaveIni()
                    buff = false
                end
            end
        end
    end
    -- ������������ ������ ��������, ������ � �������� �������� ������ �� "������� �������"
    imgui.LockPlayer = false
    imgui.ShowCursor = true
    isChangingButton = false
end

function genCode(skey) -- ��������� ���� �� GAuth (2FA)
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

function SaveIni() -- �������������� �����
    inicfg.save(mainIni, 'Luna Helper.ini')
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
        if mainIni.config.login and string.find(text, "����� ��������..") or string.find(text, "�������� ��������..") then
            return false -- ������� ������ ����� � �������� ��������, ���� ��������� �������
        end
    end
    if id == 220 then
        if mainIni.config.login and string.find(text, "������,") then 
            sampSendDialogResponse(220, 1, 65535, "") -- �������� ����� � ������� ��� ����� ������ ����� �����
            return false -- ������� ������
        end
    end
    if id == 1 and mainIni.config.login and string.find(title, "�����������") then -- �������� ������ ���� ��������� �������
        if mainIni.config.password == 'nopassword' then
            return
        else
            sampSendDialogResponse(1, 1, 65535, mainIni.config.password)
            return false -- ������� ������
        end
    end
    if id == 798 and mainIni.config.login and string.find(title, "�����������") then -- �������� 2FA ���� ��������� �������
        if mainIni.config.google == 'nogoogle' then
            return
        else
            local code = genCode(mainIni.config.google) -- ��������� 2FA ����
            sampSendDialogResponse(798, 1, 65535, code) -- ����������� ��� � �����
            return false -- ������� ������
        end
    end

    -- ������������
    if id == 484 and mainIni.config.autofuel and string.find(title, "��������") then
        if noFuel then -- �� ������ ���������� ���� ����� ��� ��� ��� �����-�� ������, ����� �� ������� ������
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
    if id == 1700 and mainIni.config.autofuel and string.find(text, "� ���������") then
        noFuel = false -- ������� ��������, ���������� false
        return false -- ����� �� ������� ������, ����� �� ���������
    end

    -- ����������� � �����������
    if id == 562 and mainIni.config.autosto and string.find(title, "������������") then -- �����������
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
    if id == 1700 and mainIni.config.autosto and string.find(text, "� ����������� �� ������� ��� ����������") then -- ���� ����� ����������� � ��� 
        sampAddChatMessage("{ff0000}* {cd70ff}[Luna Helper] {FFFFFF}����������� �� ���������. � ����������� ����������� ��� ���������.", 0xccccccAA)
        ExitSTO() -- ������� � ��� ���� �������� ������� ���������� � ��� ����� �����������
        return false -- ������� ������
    end
    if id == 1700 and mainIni.config.autosto and string.find(text, "��� �� ������� �����") then -- ���� ����� ��� �� �������
        sampAddChatMessage("{ff0000}* {cd70ff}[Luna Helper] {FFFFFF}����������� �� ���������. ��� �� ������� �����.", 0xccccccAA)
        ExitSTO() -- ������� � ��� ���� �������� ������� ���������� � ��� ����� �����������
        return false -- ������� ������
    end
    if id == 1700 and mainIni.config.autosto and string.find(text, "�� ������� �� �����������") then -- ���� �������
        return false
    end
end

function apply_custom_style() -- ������� �������
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    
    colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
    colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
    colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
    colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
    colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
    colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
    colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
    colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
    colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
    colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
    colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
    colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
    colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
    colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
    colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
    colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
    colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
    colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
    colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
    colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
end
apply_custom_style()

function onWindowMessage(msg, wparam, lparam) -- �����, � ������� �� ������ ���, ����� ��� �������� ImGui � ������� �� ������ ��� �� ������ � ���� ���� + ����������� ���� imgui
    if msg == 0x100 or msg == 0x101 then
        if (wparam == vkeys.VK_ESCAPE and show_main_window.v) and not isPauseMenuActive() then
            consumeWindowMessage(true, false)
            if msg == 0x101 then
                show_main_window.v = false
            end
        end
    end
end

function imgui.OnDrawFrame() -- �����, ������� ����������� ������ ����� ����
    if show_main_window.v then -- ���� true, �� ���������� ����
        local sw, sh = getScreenResolution() -- ���� ���������� ���� 
        local btn_size = imgui.ImVec2(-0.1, 0) -- ������ ������ (-0.1 ��������, ��� �� ����� ������ ����� ������ ������������, �������� ##[������ 1]##, ��� # - -0.1)
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) -- ������� ���� ����� ����������. ׸ ������ imgui.Cond.FirstUseEver � ��
        imgui.SetNextWindowSize(imgui.ImVec2(650, 450), imgui.Cond.FirstUseEver) -- ������ ����. �������� � ������� ���� � ������
        imgui.Begin(u8'Luna Helper ' .. lunaversion, show_main_window) -- �������� ���� + show_main_window, ����� �������� ������� ������ ������
        if imgui.Checkbox(u8'���������', autoLogin_imgui) then -- ������ � ��������
            mainIni.config.login = autoLogin_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
        end
        if imgui.Checkbox(u8'������������', autoFuel_imgui) then -- ������ � ��������
            mainIni.config.autofuel = autoFuel_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
        end
        if imgui.Checkbox(u8'�����������', autoSTO_imgui) then -- ������ � ��������
            mainIni.config.autosto = autoSTO_imgui.v
            if autoSTO_imgui.v == false then  -- ���� ����������� ���������, �� � ��������� � �� �� ���� ��������
                mainIni.config.autostoexit = false 
                autoSTOExit_imgui.v = false
            end
            inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
        end
        if autoSTO_imgui.v then -- ���� ����������� ��������, �� ������ � ����� ������ ���������� CB �� ��������� � ���  
            imgui.NewLine()
            imgui.SameLine(30.0, 0.0) -- ������� ��������
            if imgui.Checkbox(u8'��������� � ��� ����� �������', autoSTOExit_imgui) then
                mainIni.config.autostoexit = autoSTOExit_imgui.v
                inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
            end
        end
            
        if imgui.Checkbox(u8'�������/������� ��������� (L)', lockPlayer_imgui) then -- ������ � ��������
            mainIni.config.lockvehicle = lockPlayer_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
        end
        if lockPlayer_imgui.v then -- ���� ������������� ����� �� ��������\�������� �� ������, �� ���������� �������������� ���������
            imgui.NewLine()
            imgui.SameLine(30.0, 0.0) -- ������� ��������
            imgui.Text(u8'������� ������: '..vkeys.id_to_name(mainIni.config.lockvehicle_key)) -- ������ ����� ��� ��������� �������� + vkeys.id_to_name, � ������� �������� ���� ������������� �������� ������
            if not isChangingButton then -- ���� �� ��� �� ������ ������, �� ������� ����������� ������
                if imgui.Button(u8'�������� �������', btn_size) then -- ��� ������� ��������� �������� ������ � ������ ������, ����� �� �� ����� ������
                    isChangingButton = true
                    imgui.LockPlayer = true
                    imgui.ShowCursor = false
                    potok = lua_thread.create(pressNewButton) -- ��������� �����, �.�. ��������� while true
                end
            else
                if imgui.Button(u8'������� �� ��������� �������', btn_size) then -- ������ ���������� �� ����� ������ �������
                   return
                end
            end
        end
        
        imgui.Text(u8'���. ���������� �� ��� �������: ') -- ������ �����
        imgui.SameLine(0.0, -1.0) -- ������ ���, ����� ����. ������ �� ����������� �� ����� ������� � ��� �� "���������" ��� �����
        if imgui.InputInt(' ##3', autoSTOKolvo_imgui) then -- ������� ����� ����������� ��� ��������� ����� ������������ �� ��� �������
            mainIni.config.autostokolvo = autoSTOKolvo_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
        end

        imgui.NewLine()

        imgui.Text(u8'������:\t\t\t\t\t\t\t\t ') -- ������������ ���� ������� ������))) (����� ���� ������ � 2FA ��� �� ����� ������ +-)
        imgui.SameLine(0.0, -1.0) -- "���������" �����, � �� ����������� �� ����� ������
        if imgui.InputText(' ##1', pass_buffer_imgui, pass_show and 0 or imgui.InputTextFlags.Password) then -- 1) ������� ����� ����������� ��� ��������� ������. 2) ���� pass_show = true, �� �� ���������� ������ (��� ���� 0) ����� ������ ����, ������� ���������� ������� ���������� �� *
            mainIni.config.password = pass_buffer_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
        end

        imgui.Text(u8'��� 2FA (��������������): ') -- just text
        imgui.SameLine(0.0, -1.0) -- "���������" �����, � �� ����������� �� ����� ������
        if imgui.InputText(' ##2', google_buffer_imgui, google_show and 0 or imgui.InputTextFlags.Password) then -- 1) ������� ����� ����������� ��� ��������� ������. 2) ���� google_show = true, �� �� ���������� 2FA (��� ���� 0) ����� ������ ����, ������� ���������� ������� ���������� �� *
            mainIni.config.google = google_buffer_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- ��������� ������
        end
        if imgui.Checkbox(u8'�������� ������', pass_show_imgui) then -- ������ � ��������
            pass_show = pass_show_imgui.v
        end
        imgui.SameLine(0.0, -1.0) -- ����� ����������� 2 CB ��������
        if imgui.Checkbox(u8'�������� 2FA', google_show_imgui) then -- ������ � ��������
            google_show = google_show_imgui.v
        end
        
        imgui.NewLine() -- ����� ���������� ������ (��� �������)
        if imgui.Button(u8'������������� ������', btn_size) then -- ������
            showCursor(false)
            thisScript():reload()
        end
        if imgui.Button(u8'��������� ������', btn_size) then -- ������
            showCursor(false)
            sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}������ {FF0000}[��������]", 0xccccccAA)
            thisScript():unload()
        end
        if imgui.Button(u8'�������� ������', btn_size) then -- ������
            showCursor(false)
            os.remove(getWorkingDirectory().."\\config\\Luna Helper.ini")
            inicfg.load(mainIni, "..\\config\\Luna Helper.ini")
            thisScript():reload()
        end

        imgui.End()
    end
end

function TextdrawSTO() -- ����������� ���������
    if mainIni.config.autosto then
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
    if mainIni.config.autostoexit then
        local buttonexit = 12 -- �� ������ ������ � �����������
        local textexit = 20 -- �� ������ ������ � �����������
        if sampTextdrawIsExists(buttonexit) and sampTextdrawIsExists(textexit) 
        and sampTextdrawGetString(textexit) == "��xo�" then -- �������� ������ (�����)
            sampSendClickTextdraw(buttonexit) -- ������� �� ���������
        end
    end
end

function AutoLock() -- ��������/�������� �� ����� L
    if mainIni.config.lockvehicle then
        if isKeyJustPressed(mainIni.config.lockvehicle_key) and not sampIsChatInputActive() 
        and not sampIsDialogActive() and not isSampfuncsConsoleActive() then -- �������� ����� �� ����������� ���� ��� ������ � ������
            sampSendChat("/lock") -- ���� �� ��, ����� � ��� ������ ������ /lock
        end
    end
end