-- ��� ������ �� �������� Pears Project [ ���������� - Samp.Lua ]

-- ������ �������
script_name("Luna Helper")
script_author("cuzavr")
script_description("�������� Luna ��� ���� �� Test Project")
script_version("v0.1")

-- ���������
local encoding = require 'encoding'
encoding.default = 'CP1251'

-- ����������
local sampevents = require 'lib.samp.events'
local inicfg = require 'inicfg'
local mainIni = inicfg.load({
    config =
    {
        serverpass = 'chill',
        youpass = 'xyi'
    } -- ������ ��������
}, 'luna.ini')
-- ������� � ����������� � ��������
local commands = {
    ["/luna"] = {
        action = function()
            lua_thread.create(function()
                local dialogText = 
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n" ..
                "{a86cfb}��������\n" ..
                "{FF9000}/luna {FFFFFF}- ������ ������ ������ �������.\n" ..
                "{FF9000}/idea {FFFFFF}- �������� � ����� ��� � ������� � ������ �� ������.\n" ..
                "{FF9000}/bag {FFFFFF}- �������� � ����� ��� � ������� � ������ � �������-������� �����.\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n" ..
                "{a86cfb}�����������\n" ..
                "{FF9000}/luna2 {FFFFFF}- ������ ���� ������� �����������.\n" ..
                "{FF9000}/lspd /fbi /ngsa /asgh /pravo /sfpd /lvpd /swat {FFFFFF}- ������� ������ � ���.�����������.\n" ..
                "{FF9000}/lcn /yakuza /triada /rm /arab {FFFFFF}- ������� ������ � �����.\n" ..
                "{FF9000}/grove /ballas /vagos /aztec /rifa {FFFFFF}- ������� ������ � �����.\n" ..
                "{FF9000}/hitman /cable /street /biker {FFFFFF}- ������� ������ � ��������� �����������.\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n" ..
                "{a86cfb}���������\n" ..
                "{FF9000}/luna3 {FFFFFF}- ������ ���� ��������� ����� �������.\n" ..
                "{FF9000}/infernus /sultan /elegy {FFFFFF}- ���������� ����������\n" ..
                "{FF9000}/nrg {FFFFFF}- ���������� ��������\n" ..
                "{FF9000}/maverick {FFFFFF}- ���������� �������\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n"..
                "{FF9000}/lunapass [������] {FFFFFF}- �������� ������\n" ..
                "{FF9000}/lunaservpass [������ �������]{FFFFFF}- �������� ������ �������\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n"
                sampShowDialog(1, "{a86cfb}Luna Helper", dialogText, "��", "", 0)
            end)
        end
    },
    ["/luna2"] = {
        action = function()
            lua_thread.create(function()
                local dialogText = 
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n" ..
                "{a86cfb}���.�����������\n" ..
                "{FF9000}1 {FFFFFF}- {0066ff}LSPD\n" ..
                "{FF9000}2 {FFFFFF}- {6666ff}FBI\n" ..
                "{FF9000}3 {FFFFFF}- {336633}NGSA\n" ..
                "{FF9000}4 {FFFFFF}- {ff6666}ASGH\n" ..
                "{FF9000}7 {FFFFFF}- {FFFFFF}�������������\n" ..
                "{FF9000}11 {FFFFFF}- {122faa}SFPD\n" ..
                "{FF9000}21 {FFFFFF}- {2b6cc4}LVPD\n" ..
                "{FF9000}22 {FFFFFF}- {191970}SWAT\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n" ..
                "{a86cfb}�����\n" ..
                "{FF9000}5 {FFFFFF}- {cccc00}Cosa Nostra\n" ..
                "{FF9000}6 {FFFFFF}- {990000}Yakuza Mafia\n" ..
                "{FF9000}10 {FFFFFF}- {003366}Triada Mafia\n" ..
                "{FF9000}12 {FFFFFF}- {444444}������� �����\n" ..
                "{FF9000}18 {FFFFFF}- {808000}Arabian Mafia\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n" ..
                "{a86cfb}�����\n" ..
                "{FF9000}13 {FFFFFF}- {00cc00}Grove Street\n" ..
                "{FF9000}14 {FFFFFF}- {9900cc}Ballas Gang\n" ..
                "{FF9000}15 {FFFFFF}- {ffcc33}Los Santos Vagos\n" ..
                "{FF9000}16 {FFFFFF}- {00ffff}Los Aztecas\n" ..
                "{FF9000}17 {FFFFFF}- {99ffcc}SF Rifa Gang\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n" ..
                "{a86cfb}������ �����������\n" ..
                "{FF9000}8 {FFFFFF}- {999999}Hitman Agency\n" ..
                "{FF9000}9 {FFFFFF}- {ffcc66}CNN\n" ..
                "{FF9000}19 {FFFFFF}- {cccc99}Street Racers\n" ..
                "{FF9000}20 {FFFFFF}- {660000}The Bikers\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n"
                sampShowDialog(2, "{a86cfb}Luna Helper", dialogText, "��", "", 0)
            end)
        end
    },
    ["/luna3"] = {
        action = function()
            lua_thread.create(function()
                local numlist=1
                local dialogText1 = -- ���������� ���� ����������
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n" ..
                "{FF9000}2000 {FFFFFF}- Lamba Murcielago\n" ..
                "{FF9000}2001 {FFFFFF}- BMW E36 328i\n" ..
                "{FF9000}2002 {FFFFFF}- BMW M4 G82\n" ..
                "{FF9000}2003 {FFFFFF}- Mercedes S63\n" ..
                "{FF9000}2004 {FFFFFF}- Acura Integra\n" ..
                "{FF9000}2005 {FFFFFF}- Hummer H2\n" ..
                "{FF9000}2006 {FFFFFF}- Nissan GT-R R35 Tun\n" ..
                "{FF9000}2007 {FFFFFF}- Lancer Evolution IX\n" ..
                "{FF9000}2008 {FFFFFF}- Shkoda Octavia\n" ..
                "{FF9000}2009 {FFFFFF}- Mercedes C63\n" ..
                "{FF9000}2010 {FFFFFF}- Nissan 350z\n" ..
                "{FF9000}2011 {FFFFFF}- Audi Q7\n" ..
                "{FF9000}2012 {FFFFFF}- BMW 530i\n" ..
                "{FF9000}2013 {FFFFFF}- BMW 325 E30\n" ..
                "{FF9000}2014 {FFFFFF}- Mercedes G65\n" ..
                "{FF9000}2015 {FFFFFF}- Ford Raptor\n" ..
                "{FF9000}2016 {FFFFFF}- Audi RS5\n" ..
                "{FF9000}2017 {FFFFFF}- BMW 325I E30\n" ..
                "{FF9000}2018 {FFFFFF}- BMW X6M\n" ..
                "{FF9000}2019 {FFFFFF}- VW Golf\n" ..
                "{FF9000}2020 {FFFFFF}- Cadillac Fleetwood\n" ..
                "{FF9000}2021 {FFFFFF}- BMW 725il E38\n" ..
                "{FF9000}2022 {FFFFFF}- Dodge Super Bee\n" ..
                "{FF9000}2023 {FFFFFF}- Ford GT\n" ..
                "{FF9000}2024 {FFFFFF}- Lamba Centenario\n" ..
                "{FF9000}2025 {FFFFFF}- Mercedes W124\n" ..
                "{FF9000}2026 {FFFFFF}- Mercedes SL 65\n" ..
                "{FF9000}2027 {FFFFFF}- Nissan 240SX\n" ..
                "{FF9000}2028 {FFFFFF}- Porsche 911 GT2\n" ..
                "{FF9000}2029 {FFFFFF}- Shelby GT 500\n" ..
                "{FF9000}2030 {FFFFFF}- Supra MK5\n" ..
                "{FF9000}2031 {FFFFFF}- Toyota GT AE86\n" ..
                "{FF9000}2032 {FFFFFF}- Prison Bus\n" ..
                "{FF9000}2033 {FFFFFF}- Mercedes AMG GT63\n" ..
                "{FF9000}2034 {FFFFFF}- Bentley Cabriolet\n" ..
                "{FF9000}2035 {FFFFFF}- BMW 325 I30\n" ..
                "{FF9000}2036 {FFFFFF}- Arm Cargo\n" ..
                "{FF9000}2037 {FFFFFF}- Ford Raptor\n" ..
                "{FF9000}2038 {FFFFFF}- Charger Police\n" ..
                "{FF9000}2039 {FFFFFF}- Charger Dep\n" ..
                "{FF9000}2040 {FFFFFF}- Enforcer SWAT\n" ..
                "{FF9000}2041 {FFFFFF}- Truck SWAT\n" ..
                "{FF9000}2042 {FFFFFF}- Ferrari F1\n" ..
                "{FF9000}2043 {FFFFFF}- Crown Vic\n" ..
                "{FF9000}2044 {FFFFFF}- Crown Vic Dep\n" ..
                "{FF9000}2045 {FFFFFF}- Expedition\n" ..
                "{FF9000}2046 {FFFFFF}- Explorer Dep\n" ..
                "{FF9000}2047 {FFFFFF}- Explorer Police\n" ..
                "{FF9000}2048 {FFFFFF}- Ford Focus ST\n" ..
                "{FF9000}2049 {FFFFFF}- Nissan Silvia S13\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n"

                local dialogText2 =
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n"..
                "{FF9000}2050 {FFFFFF}- Jeep Wrangler\n" ..
                "{FF9000}2051 {FFFFFF}- Lexus LS400\n" ..
                "{FF9000}2052 {FFFFFF}- Lexus RCF\n" ..
                "{FF9000}2053 {FFFFFF}- Mazda RX7\n" ..
                "{FF9000}2054 {FFFFFF}- Mercedes EQS 580\n" ..
                "{FF9000}2055 {FFFFFF}- Mercedes Sprinter\n" ..
                "{FF9000}2056 {FFFFFF}- Ferrari Enzo\n" ..
                "{FF9000}2057 {FFFFFF}- Mercedes E63\n" ..
                "{FF9000}2058 {FFFFFF}- Mitsu Eclipse\n" ..
                "{FF9000}2059 {FFFFFF}- Silvia S14\n" ..
                "{FF9000}2060 {FFFFFF}- Hummer H1\n" ..
                "{FF9000}2061 {FFFFFF}- Plymouth Hemi\n" ..
                "{FF9000}2062 {FFFFFF}- Camry Taxi\n" ..
                "{FF9000}2063 {FFFFFF}- Vaz 2106\n" ..
                "{FF9000}2064 {FFFFFF}- Vaz 2107\n" ..
                "{FF9000}2065 {FFFFFF}- VW Golf MK2\n" ..
                "{FF9000}2066 {FFFFFF}- BMW 7\n" ..
                "{FF9000}2067 {FFFFFF}- Chaser JZX100\n" ..
                "{FF9000}2068 {FFFFFF}- BMW M5 F90\n" ..
                "{FF9000}2069 {FFFFFF}- Audi R8\n" ..
                "{FF9000}2070 {FFFFFF}- Rolls Wraith\n" ..
                "{FF9000}2071 {FFFFFF}- Rolls Cullinan\n" ..
                "{FF9000}2072 {FFFFFF}- Pagani Zonda\n" ..
                "{FF9000}2073 {FFFFFF}- Range Rover\n" ..
                "{FF9000}2074 {FFFFFF}- Nissan GT-R R34\n" ..
                "{FF9000}2075 {FFFFFF}- Silvia S15\n" ..
                "{FF9000}2076 {FFFFFF}- Nissan GT-R R35\n" ..
                "{cccccc}----------------------------------------------------------------------------------------------------------------------\n"

                while true do -- ��� ���� ������ �������

                    -- ����� �������� �� ������������� ����������
                    if numlist==1 then 
                        sampShowDialog(3, "{a86cfb}Luna Helper", dialogText1, "�����", "�����", 0)
                    elseif numlist==2  then 
                        sampShowDialog(3, "{a86cfb}Luna Helper", dialogText2, "�����", "�����", 0)
                    else 
                        break -- ���� ����� �������� ����, �� ���� ��������� ������
                    end 

                    while sampIsDialogActive(3) do wait(100) end --��� ���� ����� ���-������ �� ������� 
                    local _, buttonl3, _, _ = sampHasDialogRespond(3) -- ���������� ������ ������ ��� �������� ������ (�� ��������� - ��� "_")
                    if buttonl3 == 1 then -- ���� ������ "�����"
                        numlist=numlist+1
                    else -- ���� ������ "�����"
                        numlist=numlist-1
                    end
                end
            end)
        end
    },
    ["/idea"] = {
        action = function()
            lua_thread.create(function()
                sampSendChat("/o ���� �� �������� ����������� �� ������ ������� - forum.pears.fun")
                sampSendChat("/o ������: �������� ����� - ����������� �� ���������")
            end)
        end
    },
    ["/bag"] = {
        action = function()
            lua_thread.create(function()
                sampSendChat("/o ����� ���? �������� � �� � �������-������� ������ �������,")
                sampSendChat("/o discord.gg/9C4UgEqE2g [ � ��������� ������� ����� ����� ���� ]")
            end)
        end
    },
    -- �����
    ["/lspd"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 1")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {0066ff}LSPD {FF9000}[ /lspd id ] ", -1)
            end
        end
    },
    ["/fbi"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 2")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {6666ff}FBI {FF9000}[ /fbi id ] ", -1)
            end
        end
    },
    ["/ngsa"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 3")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {336633}NGSA {FF9000}[ /ngsa id ] ", -1)
            end
        end
    },
    ["/asgh"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 4")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {ff6666}ASGH {FF9000}[ /asgh id ] ", -1)
            end
        end
    },
    ["/pravo"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 7")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {ffffff}������������� {FF9000}[ /pravo id ] ", -1)
            end
        end
    },
    ["/sfpd"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 11")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {122faa}SFPD {FF9000}[ /sfpd id ] ", -1)
            end
        end
    },
    ["/lvpd"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 21")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {2b6cc4}LVPD {FF9000}[ /lvpd id ] ", -1)
            end
        end
    },
    ["/swat"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 20")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {191970}SWAT {FF9000}[ /swat id ] ", -1)
            end
        end
    },
    -- �����
    ["/lcn"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 5")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {cccc00}Cosa Nostra {FF9000}[ /lcn id ] ", -1)
            end
        end
    },
    ["/yakuza"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 6")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {990000}Yakuza Mafia {FF9000}[ /yakuza id ] ", -1)
            end
        end
    },
    ["/triada"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 10")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {003366}Triada Mafia {FF9000}[ /triada id ] ", -1)
            end
        end
    },
    ["/rm"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 12")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {444444}������� ����� {FF9000}[ /rm id ] ", -1)
            end
        end
    },
    ["/arab"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 18")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {808000}Arabian Mafia {FF9000}[ /arab id ] ", -1)
            end
        end
    },
    -- �����
    ["/grove"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 13")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {00cc00}Grove Street {FF9000}[ /grove id ] ", -1)
            end
        end
    },
    ["/ballas"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 14")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {9900cc}Ballas Gang {FF9000}[ /ballas id ] ", -1)
            end
        end
    },
    ["/vagos"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 15")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {ffcc33}Los Santos Vagos {FF9000}[ /vagos id ] ", -1)
            end
        end
    },
    ["/aztec"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 16")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {00ffff}Los Aztecas {FF9000}[ /aztec id ] ", -1)
            end
        end
    },
    -- ��������� �����������
    ["/hitman"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 8")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {999999}Hitman Agency {FF9000}[ /hitman id ] ", -1)
            end
        end
    },
    ["/cable"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 9")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {ffcc66}CNN {FF9000}[ /cable id ] ", -1)
            end
        end
    },
    ["/rifa"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 17")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {99ffcc}SF Rifa Gang {FF9000}[ /rifa id ] ", -1)
            end
        end
    },
    ["/street"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 19")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {cccc99}Street Racers {FF9000}[ /street id ] ", -1)
            end
        end
    },
    ["/biker"] = {
        action = function(playerId)
            if playerId then
                sampSendChat("/au " .. playerId)
                sampSendChat("/ai " .. playerId .. " 20")
            else
                sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������� ������ � {660000}The Bikers {FF9000}[ /biker id ] ", -1)
            end
        end
    },
    -- ����������
    ["/infernus"] = {
        action = function(playerId)
            sampSendChat("/veh 411 6 6")
        end
    },
    ["/sultan"] = {
        action = function(playerId)
            sampSendChat("/veh 560 6 6")
        end
    },
    ["/elegy"] = {
        action = function(playerId)
            sampSendChat("/veh 562 6 6")
        end
    },
    -- ���������
    ["/nrg"] = {
        action = function(playerId)
            sampSendChat("/veh 522 6 6")
        end
    },
    -- ��������
    ["/maverick"] = {
        action = function(playerId)
            sampSendChat("/veh 487 6 6")
        end
    },

}
-- �������
function main()
    while not isSampAvailable() do wait(0) end
    -- ���� �� �������� ������ �����
    local ip, port = sampGetCurrentServerAddress()
    if ip ~= "54.37.139.10" or port ~= 8792 then
        sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������ �� �������� {FF9000}[ �������� ������ �� �������� ������� Pears Project ]", -1)
        thisScript():unload()
        return 0
    end
    if not doesFileExist("moonloader/config/luna.ini") then inicfg.save(mainIni, "luna.ini") end -- ���� ����� ���, �� ������ (���� ��������� � �� � ��� ����� ��������)
    sampAddChatMessage("{a86cfb}[ Luna Helper ]: {FFFFFF}������ ������� �������� {FF9000}[ /luna ]", -1)
    sampProcessChatInput('/servpass '..mainIni.config.serverpass) -- ����������� �� cfg

    sampRegisterChatCommand("lunapass", lunapass_f)
    sampRegisterChatCommand("lunaservpass", lunaservpass_f)

    while (true) and (is_pears) do
        wait(0)
    end
end

function lunapass_f(arg)
    if arg == "" then 
        sampAddChatMessage("������� /lunapass [������]", -1)
        return 0
    end

    mainIni.config.youpass = arg
    inicfg.save(mainIni, "luna.ini")
    sampAddChatMessage("��� ������ ������� ������ �� "..arg, -1)
end

function lunaservpass_f(arg)
    if arg == "" then 
        sampAddChatMessage("������� /lunaservpass [������ �������]", -1)
        return 0
    end

    mainIni.config.serverpass = arg
    inicfg.save(mainIni, "luna.ini")
    sampAddChatMessage("��� ������ ������� ������� ������ �� "..arg, -1)
end

function sampevents.onSendCommand(command)

    local parts = {}
    for part in command:gmatch("%S+") do
        parts[#parts + 1] = part
    end

    local cmd = parts[1]
    local playerId = parts[2]

    local cmdInfo = commands[cmd]
    if cmdInfo then
        cmdInfo.action(playerId)
        return false
    end
end

-- �������� ������
function sampevents.onShowDialog(id, style, title, button1, button2, text)

    if id == 1 then
        sampSendDialogResponse(id, 1, 0, mainIni.config.youpass) -- ����������� �� cfg
        return false
    end
end