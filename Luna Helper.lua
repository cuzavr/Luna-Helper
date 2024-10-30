--[[ 
Для работы на лаунчере Pears Project [ Библиотеки - Samp.Lua ] 
Если своя сборка, то нужнен sampfuncs, также библиотеки для луа sha1, basexx
--]]

-- Информация о скрипте
script_name("Luna Helper")
script_author("cuzavr")
script_description("Помощник для игры на Pears Project")
script_version("v0.2")

-- Кодировка
local encoding = require 'encoding'
encoding.default = 'CP1251'

-- Библиотеки и прочее
local sampevents = require 'lib.samp.events'
require 'sampfuncs'
local inicfg = require 'inicfg'
local mainIni = inicfg.load({
    config =
    {
        login = 0, -- Автологин, 0 - выкл, 1 - вкл
        password = 'nopassword', -- Пароль от аккаунта (Для автологина)
        google = 'nogoogle', -- 2FA от аккаунта (Для автологина)
        autofuel = 0 -- Автозаправка, 0 - выкл, 1 - вкл
    } -- дефолт значения
}, 'Luna Helper.ini')

-- Для 2FA
local sha1 = require('sha1')
local basexx = require('basexx')

-- Таблица с информацией о командах
local commands = {
    -- Основное
    ["/luna"] = {
        action = function()
            lua_thread.create(function()
                local dialogText = 
                "{cccccc}Основное\n" ..
                "{cd70ff}/luna {FFFFFF}- Полный список команд скрипта.\n" ..
                "{cd70ff}/lunard {FFFFFF}- Перезагрузить скрипт.\n" ..
                "{cd70ff}/lunabb {FFFFFF}- Отгрузить скрипт.\n" ..

                "{cccccc}\nКонфиг Скрипта\n" ..
                "{cd70ff}/lunalg {FFFFFF}- Включить/Выключить автологин.\n" ..
                "{cd70ff}/lunaaf {FFFFFF}- Включить/Выключить автозаправку.\n" ..
                "{cd70ff}/lunapass [Пароль] {FFFFFF}- Изменить пароль для автологина.\n" ..
                "{cd70ff}/lunagoogle [2FA] {FFFFFF}- Изменить 2FA для автологина.\n"
                sampShowDialog(1, "{FF9000}Luna Helper", dialogText, "ОК", "", 0)
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
                sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Скрипт {FF0000}[Отгружен]", 0xccccccFF)
                thisScript():unload()
            end)
        end
    },

    -- Конфиг Скрипта
    ["/lunalg"] = { -- Автологин
        action = function()
            lua_thread.create(function()
                if mainIni.config.login == 0 then -- Если выключен, включаем и сохраняем конфиг
                    mainIni.config.login = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Автологин {00ff00}[ON]", 0xccccccFF)
                elseif mainIni.config.login == 1 then -- Если включен, выключаем и сохраняем конфиг
                    mainIni.config.login =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Автологин {FF0000}[OFF]", 0xccccccFF)
                end
            end)
        end
    },
    ["/lunaaf"] = { -- Автозаправка
        action = function()
            lua_thread.create(function()
                if mainIni.config.autofuel == 0 then -- Если выключен, включаем и сохраняем конфиг
                    mainIni.config.autofuel = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Автозаправка {00ff00}[ON]", 0xccccccFF)
                elseif mainIni.config.autofuel == 1 then -- Если включен, выключаем и сохраняем конфиг
                    mainIni.config.autofuel =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Автозаправка {FF0000}[OFF]", 0xccccccFF)
                end
            end)
        end
    },
}
-- Функции
function main() -- Основная функция, подгружаемая при загрузке скрипта
    while not isSampAvailable() do wait(0) end
    local ip, port = sampGetCurrentServerAddress()
    if ip ~= "185.169.132.133" and port ~= 7777 then -- Pears Project
        thisScript():unload() -- Отгружаем скрипт, если юзер заходит на другой сервер
        return 0
    end
    if not doesFileExist("moonloader/config/Luna Helper.ini") then 
        sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Вы запускаете скрипт в первый раз. Конфиг был успешно создан!", 0xccccccFF)
    end
    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Скрипт успешно загружен {FF9000}[ /luna ]", 0xccccccFF)
    sampRegisterChatCommand("lunapass", lunapass_f) -- Пароль от аккаунта
    sampRegisterChatCommand("lunagoogle", lunagoogle_f) -- 2FA от аккаунта
    inicfg.save(mainIni, "Luna Helper.ini") -- При запуске скрипта сохраняем конфиг (Если нет конфига, он создаётся в таком случае)

    while (true) and (is_pears) do
        wait(0)
    end
end

function genCode(skey) -- Генерация кода по GAuth
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

function lunapass_f(arg) -- Смена пароля от аккаунта для автологина
    if arg == "" then -- Если ничего не было введено
        sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Изменить пароль от автологина {FF9000} [ /lunapass пароль ]", 0xccccccFF)
        return 0
    end

    mainIni.config.password = arg -- Получаем новый пароль
    inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Пароль изменён на {FF9000}"..arg, 0xccccccFF) -- Сообщаем, что пароль сохранён
end

function lunagoogle_f(arg) -- Смена 2FA от аккаунта для автологина
    if arg == "" then -- Если ничего не было введено
        sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Изменить ключ 2FA от автологина {FF9000} [ /lunapass Ключ ]", 0xccccccFF)
        return 0
    end

    mainIni.config.google = arg -- Получаем новый 2FA
    inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
    sampAddChatMessage("{cd70ff}[Luna Helper] {FFFFFF}Ключ от 2FA изменён на {FF9000}"..arg, 0xccccccFF) -- Сообщаем, что 2FA сохранён
end

function sampevents.onSendCommand(command) -- Функция для ввода различных команд

    local parts = {}
    for part in command:gmatch("%S+") do
        parts[#parts + 1] = part
    end

    local cmd = parts[1] -- Команда
    local playerId = parts[2] -- ID игрока

    local cmdInfo = commands[cmd]
    if cmdInfo then
        cmdInfo.action(playerId)
        return false
    end
end

function sampevents.onShowDialog(id, style, title, button1, button2, text) -- Диалоги
    -- Автологин
    if id == 1290 or id == 1291 then 
        if mainIni.config.login == 1 and string.find(text, "Поиск аккаунта..") or string.find(text, "Загрузка аккаунта..") then 
            return false -- Убираем диалог поиск и загрузка аккаунта, если автологин включен
        end
    end
    if id == 1 and mainIni.config.login == 1 and string.find(title, "Авторизация") then -- Автоввод пароля если автологин включен
        if mainIni.config.password == 'nopassword' then
            return
        else
            sampSendDialogResponse(id, 1, 65535, mainIni.config.password)
            return false -- Убираем диалог
        end
    end
    if id == 798 and mainIni.config.login == 1 and string.find(title, "Авторизация") then -- Автоввод 2FA если автологин включен
        if mainIni.config.google == 'nogoogle' then
            return
        else
            local code = genCode(mainIni.config.google) -- Генерация 2FA кода
            sampSendDialogResponse(798, 1, 65535, code) -- Подставляем код в ответ
            return false -- Убираем диалог
        end
    end

    -- Автозаправка
    if id == 484 and mainIni.config.autofuel == 1 and string.find(title, "Заправка") then
        local liters = text:match("Для полного бака вам требуется: (%d+) литров")
        if liters then -- Если получено максимальное кол-во литров, которое можно заправить
            sampSendDialogResponse(484, 1, 65535, liters) -- Заправляем на максимальное кол-во литров
            return false -- Сразу же убираем диалог, чтобы не раздражал
        end
    end
end