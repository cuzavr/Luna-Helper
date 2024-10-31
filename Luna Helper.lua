--[[ 
Для работы на лаунчере Pears Project [ Библиотеки - Samp.Lua ] 
Если своя сборка, то нужнен sampfuncs, также библиотеки для луа sha1, basexx
--]]

-- Информация о скрипте
script_name("Luna Helper")
script_author("cuzavr")
script_description("Помощник для игры на Pears Project")
script_version("v0.4.1")

-- Кодировка
local encoding = require 'encoding'
encoding.default = 'CP1251'

-- Библиотеки и прочее
local sampevents = require 'lib.samp.events'
require 'sampfuncs'
local inicfg = require 'inicfg'
local vkeys = require 'vkeys'
local mainIni = inicfg.load({ -- Дефолт значения в конфиге
    config = {
        password = 'nopassword', -- Пароль от аккаунта (Для автологина)
        google = 'nogoogle', -- 2FA от аккаунта (Для автологина)
        autoupdate = 1, -- Автообновление скрипта, 0 - выкл, 1 - вкл

        login = 0, -- Автологин, 0 - выкл, 1 - вкл
        autofuel = 0, -- Автозаправка, 0 - выкл, 1 - вкл
        autosto = 0, -- Автопочинка в Автосервисе, 0 - выкл, 1 - вкл
        autostoexit = 0, -- Автовыход с Автосервиса после Автопочинки, 0 - выкл, 1 - вкл
        lockvehicle = 0, -- При нажатии на L открыть/закрыть транспорт, 0 - выкл, 1 - вкл
        autostokolvo = 999 -- Для автопочинки в Автосервисе, если сток хп и меньше то чинит
    }
}, 'Luna Helper.ini')

-- https://github.com/qrlk/moonloader-script-updater
local autoupdate_loaded = false
local Update = nil

-- Для 2FA
local sha1 = require('sha1')
local basexx = require('basexx')

-- Для автозаправки
local clickedSTOSto = false

-- Таблица с информацией о командах
local commands = {
    -- Основное
    ["/luna"] = {
        action = function()
            lua_thread.create(function()
                -- Автообновление скрипта
                local autoupdateStatus = mainIni.config.autoupdate == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- Автологин
                local autoLoginStatus = mainIni.config.login == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- Автозаправка
                local autoFuelStatus = mainIni.config.autofuel == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- Автопочинка
                local autoStoStatus = mainIni.config.autosto == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                local autostokolvoStatus = mainIni.config.autostokolvo
                local autoStoExitStatus = mainIni.config.autostoexit == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- Открыть/Закрыть транспорт при нажатии на клавишу L
                local lockvehicleStatus = mainIni.config.lockvehicle == 1 and "{00ff00}[ON]" or "{FF0000}[OFF]"
                -- Пароль и гугл
                local password = mainIni.config.password == 'nopassword' and "{FF0000}[Не установлен]" or "{00ff00}[Установлен]"
                local google = mainIni.config.google == 'nogoogle' and "{FF0000}[Не установлен]" or "{00ff00}[Установлен]"

                local dialogText = 
                "{cecece}Команды Скрипта\n" ..
                "{cccccc}/luna {FFFFFF}- Меню скрипта.\n" ..
                "{cccccc}/lunard {FFFFFF}- Перезагрузить скрипт.\n" ..
                "{cccccc}/lunabb {FFFFFF}- Отгрузить скрипт.\n" ..
                "{cccccc}/lunacf {FFFFFF}- Сбросить конфиг скрипта.\n" ..
                "{cccccc}/lunaupdate {FFFFFF}- Обновить скрипт.\n" ..

                "\n{cccccc}/lunaau {FFFFFF}- Включить/Выключить автообновление скрипта.\n" ..
                "{cccccc}/lunalg {FFFFFF}- Включить/Выключить автологин.\n" ..
                "{cccccc}/lunaaf {FFFFFF}- Включить/Выключить автозаправку.\n" ..
                "{cccccc}/lunaas {FFFFFF}- Включить/Выключить автопочинку в Автосервисе.\n" ..
                "{cccccc}/lunaask {FFFFFF}- Изменить кол-во хп в автопочинке, чтобы при таком и меньше чинилось.\n" ..
                "{cccccc}/lunaaske {FFFFFF}- Включить/Выключить Автовыход после Автопочинки.\n" ..

                "\n{cccccc}/lunalock {FFFFFF}- Включить/Выключить функцию открытия/закрытия транспорта на клавишу {FF9000}[L]\n" ..

                "\n{cccccc}/lunapass {FFFFFF}- Изменить пароль для автологина.\n" ..
                "{cccccc}/lunagoogle {FFFFFF}- Изменить 2FA для автологина.\n" ..

                "{cecece}\nВаши Настройки\n" ..
                "{cccccc}Автообновление скрипта " .. autoupdateStatus .. "\n" ..
                "{cccccc}Автологин " .. autoLoginStatus .. "\n" ..
                "{cccccc}Автозаправка " .. autoFuelStatus .. "\n" ..
                "{cccccc}Автопочинка в Автосервисе " .. autoStoStatus .. "\n" ..
                "{cccccc}Автовыход с Автосервиса после Автопочинки " .. autoStoExitStatus .. "\n" ..
                "{cccccc}Открытие/Закрытие транспорта при нажатии на клавишу L " .. lockvehicleStatus .. "\n" ..

                "\n{cccccc}Пароль " .. password .. "\n" ..
                "{cccccc}2FA " .. google .. "\n" ..
                "{cccccc}ХП для Автопочинки в Автосервисе {FF9000}[" .. autostokolvoStatus .. "]\n"

                sampShowDialog(1, "{FF9000}Luna Helper v0.4", dialogText, "ОК", "", 0)
            end)
        end
    },
    ["/lunaupdate"] = {
        action = function()
            lua_thread.create(function()
                LunaUpdate()
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
                sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Скрипт {FF0000}[Отгружен]", 0xcececeFF)
                thisScript():unload()
            end)
        end
    },
    ["/lunacf"] = {
        action = function()
            lua_thread.create(function()
                os.remove(getWorkingDirectory().."\\config\\Luna Helper.ini")
                inicfg.load(mainIni, "..\\config\\Luna Helper.ini")
                thisScript():reload()
            end)
        end
    },

    -- Конфиг Скрипта
    ["/lunaau"] = { -- Автообновление скрипта включить/выключить
        action = function()
            lua_thread.create(function()
                if mainIni.config.autoupdate == 0 then -- Если выключен, включаем и сохраняем конфиг
                    mainIni.config.autoupdate = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автообновление скрипта {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.autoupdate == 1 then -- Если включен, выключаем и сохраняем конфиг
                    mainIni.config.autoupdate =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автообновление скрипта {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    ["/lunalg"] = { -- Автологин
        action = function()
            lua_thread.create(function()
                if mainIni.config.login == 0 then -- Если выключен, включаем и сохраняем конфиг
                    mainIni.config.login = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автологин {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.login == 1 then -- Если включен, выключаем и сохраняем конфиг
                    mainIni.config.login =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автологин {FF0000}[OFF]", 0xcececeFF)
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
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автозаправка {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.autofuel == 1 then -- Если включен, выключаем и сохраняем конфиг
                    mainIni.config.autofuel =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автозаправка {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    -- Автопочинка в Автосервисе
    ["/lunaas"] = {
        action = function()
            lua_thread.create(function()
                if mainIni.config.autosto == 0 then -- Если выключен, включаем и сохраняем конфиг
                    mainIni.config.autosto = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автопочинка в Автосервисе {00ff00}[ON]", 0xcececeFF)
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автопочинка срабатывает, если у транспорта меньше или равно хп, сколько указано в конфиге.", 0xcececeFF)
                elseif mainIni.config.autosto == 1 then -- Если включен, выключаем и сохраняем конфиг
                    mainIni.config.autosto = 0
                    mainIni.config.autostoexit = 0 -- Автовыход тож оффаем чё бы нет
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автопочинка в Автосервисе {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    ["/lunaaske"] = {
        action = function()
            lua_thread.create(function()
                if mainIni.config.autostoexit == 0 then -- Если выключен, включаем и сохраняем конфиг
                    mainIni.config.autostoexit = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автовыход после Автопочинки {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.autostoexit == 1 then -- Если включен, выключаем и сохраняем конфиг
                    mainIni.config.autostoexit =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Автовыход после Автопочинки {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    -- Бинды
    ["/lunalock"] = { -- При нажатии на L будет прописывать за игрока /lock
        action = function()
            lua_thread.create(function()
                if mainIni.config.lockvehicle == 0 then -- Если выключен, включаем и сохраняем конфиг
                    mainIni.config.lockvehicle = 1
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Открытие/Закрытие транспорта при нажатии на клавишу L {00ff00}[ON]", 0xcececeFF)
                elseif mainIni.config.lockvehicle == 1 then -- Если включен, выключаем и сохраняем конфиг
                    mainIni.config.lockvehicle =  0
                    inicfg.save(mainIni, "Luna Helper.ini")
                    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Открытие/Закрытие транспорта при нажатии на клавишу L {FF0000}[OFF]", 0xcececeFF)
                end
            end)
        end
    },
    ["/test"] = {
        action = function()
            lua_thread.create(function()
                sampAddChatMessage(sampTextdrawGetString(20))
            end)
        end
    },
}
-- Функции
function main() -- Основная функция, подгружаемая при загрузке скрипта
    while not isSampAvailable() do wait(0) end
    -- Автоапдейт
    if mainIni.config.autoupdate == 1 then
        LunaUpdate()
    end
    
    local ip, port = sampGetCurrentServerAddress()
    if ip ~= "185.169.132.133" and port ~= 7777 then -- Pears Project
        thisScript():unload() -- Отгружаем скрипт, если юзер заходит на другой сервер
        return 0
    end
    if not doesFileExist("moonloader/config/Luna Helper.ini") then 
        sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Вы запускаете скрипт в первый раз. Конфиг был успешно создан!", 0xcececeFF)
    end
    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Скрипт успешно загружен {FF9000}[ /luna ]", 0xcececeFF)

    sampRegisterChatCommand("lunapass", lunapass_f) -- Пароль от аккаунта
    sampRegisterChatCommand("lunagoogle", lunagoogle_f) -- 2FA от аккаунта
    sampRegisterChatCommand("lunaask", lunaask_f) -- ХП для Автопочинки в Автосервисе

    inicfg.save(mainIni, "Luna Helper.ini") -- При запуске скрипта сохраняем конфиг (Если нет конфига, он создаётся в таком случае)

    while true do
        wait(0)
        TextdrawSTO() -- Текстдрав СТО
        AutoLock() -- Открытие и закрытии тс при нажатии на L
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
        sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Изменить пароль от автологина {FF9000} [ /lunapass пароль ]", 0xcececeFF)
        return 0
    end

    mainIni.config.password = arg -- Получаем новый пароль
    inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Пароль изменён на {FF9000}"..arg, 0xcececeFF) -- Сообщаем, что пароль сохранён
end

function lunagoogle_f(arg) -- Смена 2FA от аккаунта для автологина
    if arg == "" then -- Если ничего не было введено
        sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Изменить ключ 2FA от автологина {FF9000} [ /lunapass Ключ ]", 0xcececeFF)
        return 0
    end

    mainIni.config.google = arg -- Получаем новый 2FA
    inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Ключ от 2FA изменён на {FF9000}"..arg, 0xcececeFF) -- Сообщаем, что 2FA сохранён
end

function lunaask_f(arg) -- Смена ХП для автопочинки в Автосервисе
    if arg == "" then -- Если ничего не было введено
        sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Изменить ХП для автопочинки в Автосервисе {FF9000} [ /lunaask кол-во ]", 0xcececeFF)
        return 0
    end

    local new_hp = tonumber(arg) -- Преобразуем arg в число
    if not new_hp then -- Проверка на случай, если ввод был нечисловым
        sampAddChatMessage("{FF0000}Ошибка: введите числовое значение!", 0xFF0000)
        return 0
    end

    mainIni.config.autostokolvo = new_hp -- Сохраняем преобразованное значение
    inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
    sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}ХП автопочинки изменено на {FF9000}"..new_hp, 0xcececeFF)
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
    if id == 220 then
        if mainIni.config.login == 1 and string.find(text, "Привет,") then 
            sampSendDialogResponse(220, 1, 65535, "") -- Нажимаем далее в диалоге где пишет привет нажми Ентер
            return false -- Убираем диалог
        end
    end
    if id == 1 and mainIni.config.login == 1 and string.find(title, "Авторизация") then -- Автоввод пароля если автологин включен
        if mainIni.config.password == 'nopassword' then
            return
        else
            sampSendDialogResponse(1, 1, 65535, mainIni.config.password)
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
    if id == 1700 and mainIni.config.autofuel == 1 and string.find(text, "Я заправляю") then
        return false -- Сразу же убираем диалог, чтобы не раздражал
    end

    -- Автопочинка в Автосервисе
    if id == 562 and mainIni.config.autosto == 1 and string.find(title, "Обслуживание") then
        if isCharInAnyCar(PLAYER_PED) then
            local autostokolvo = mainIni.config.autostokolvo -- Получаем с конфига хп установленное
            local car = storeCarCharIsInNoSave(PLAYER_PED) -- Проверка на тс
            local health = getCarHealth(car) -- Проверка хп тс
            
            if health <= autostokolvo then -- Проверка хп, если у тс меньше или равно значения с конфига чиним
                local responseID = 1 -- Один это Полный Ремонт, его идшник крч
                sampSendDialogResponse(562, responseID)  -- Выбираем его
                ExitSTO() -- Функция автовыхода с Автосервиса
                return false
            end
        end
    end
    if id == 1700 and mainIni.config.autosto == 1 and string.find(text, "Вы выехали из автосервиса") then -- Скип диалога
        return false
    end
end

function TextdrawSTO() -- Автопочинка текстдрав
    if mainIni.config.autosto == 1 then
        local buttonSTO = 13 -- ИД кнопки
        local textSTO = 16 -- ИД текста
        local autostokolvo = tonumber(mainIni.config.autostokolvo) -- Получаем с конфига хп установленное

        if isCharInAnyCar(PLAYER_PED) then
            local car = storeCarCharIsInNoSave(PLAYER_PED) -- Проверка на тс
            local health = getCarHealth(car) -- Проверка хп тс
            
            if health <= autostokolvo then -- Проверка хп, если у тс меньше или равно значения с конфига чиним
                if sampTextdrawIsExists(buttonSTO) 
                and sampTextdrawIsExists(textSTO) and sampTextdrawGetString(textSTO) == "O—cћy›њўa®њe" -- Проверка текста
                and not clickedSTO then
                    sampSendClickTextdraw(buttonSTO) -- Кликаем на текстдрав
                    clickedSTO = true -- Чтобы не кликать снова
                elseif not sampTextdrawIsExists(buttonSTO) then
                    clickedSTO = false -- Чтобы в след раз кликнул снова
                end
            end
        end
    end
end

function ExitSTO() -- Автовыход с Автосервиса
    if mainIni.config.autostoexit == 1 then
        local buttonexit = 12 -- ИД кнопки выхода с автосервиса
        local textexit = 20 -- ИД текста выхода с автосервиса
        if sampTextdrawIsExists(buttonexit) and sampTextdrawIsExists(textexit) 
        and sampTextdrawGetString(textexit) == "‹Ёxoљ" then
            sampSendClickTextdraw(buttonexit) -- Кликаем на текстдрав
        end
    end
end

function AutoLock()
    if mainIni.config.lockvehicle == 1 then
        if isKeyJustPressed(vkeys.VK_L) and not sampIsChatInputActive() 
        and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
            sampSendChat("/lock")
        end
    end
end

function LunaUpdate() -- Обновление скрипта
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) 
        -- Краткая версия кода автообновления, оставим существующий код
    }]])

    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://github.com/cuzavr/Luna-Helper/raw/refs/heads/main/version.json" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/cuzavr/Luna-Helper"
        end
    else
        sampAddChatMessage("{cccccc}[Luna Helper] {FFFFFF}Не удалось загрузить функцию автообновления.", 0xcececeFF)
    end
end