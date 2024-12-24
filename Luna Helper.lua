--[[ Для работы на лаунчере Pears Project [ Библиотеки - Samp.Lua, Sampfuncs, Moon Imgui ] 
Также библиотеки для луа sha1, basexx --]]

-- Информация о скрипте
script_name("Luna Helper")
script_author("cuzavr")
script_description("Помощник для игры на Pears Project")
script_version("v0.5.1")

-- Библиотеки
local encoding = require 'encoding' -- Кодировка
encoding.default = 'CP1251' -- Кодировка
local sampevents = require 'lib.samp.events' -- Для получения событий сампа (Диалоги к примеру)
require 'sampfuncs' -- Sampfuncs
local vkeys = require 'vkeys' -- Для получения клавиш и их применение
local sha1 = require 'sha1' -- Для 2FA
local basexx = require 'basexx' -- Для 2FA
local imgui = require 'imgui' -- Для визуальной менюшки

-- Конфиг скрипта
local inicfg = require 'inicfg'
local mainIni = inicfg.load({ -- Дефолт значения в конфиге
    config = {
        -- Основное
        password = 'nopassword', -- Пароль от аккаунта (Для автологина)
        google = 'nogoogle', -- 2FA от аккаунта (Для автологина)

        -- Автоматические системы. false - выкл, true - вкл
        login = false, -- Автологин
        autofuel = false, -- Автозаправка
        autosto = false, -- Автопочинка в Автосервисе
        autostoexit = false, -- Автовыход с Автосервиса после Автопочинки
        lockvehicle = false, -- При нажатии на lockvehicle_key открыть/закрыть транспорт
        lockvehicle_key = vkeys.VK_L,

        -- Прочее
        autostokolvo = 999 -- Для автопочинки в Автосервисе, если столько хп и меньше то чинит
    }
}, 'Luna Helper.ini')

-- Прочее
local lunaversion = "v0.5.1" -- Версия скрипта для диалогов и тд
local clickedSTO = false -- Для автопочинки
local noFuel = false -- Для автозаправки

-- Имгуишечка (imgui)
u8 = encoding.UTF8 -- чтобы imgui поддерживала русские символы (юзается как: u8"[ПРОИЗВОЛЬНЫЙ_ТЕКСТ]")
show_main_window = imgui.ImBool(false) -- Показ\скрытие окна
local autoLogin_imgui = imgui.ImBool(mainIni.config.login) -- CheckBox (далее CB - квадратик с галочкой) для автологина
local lockPlayer_imgui = imgui.ImBool(mainIni.config.lockvehicle) -- CB для кнопки закрытия\открытия машины
local autoFuel_imgui = imgui.ImBool(mainIni.config.autofuel) -- CB для автозаправки
local autoSTO_imgui = imgui.ImBool(mainIni.config.autosto) -- CB для автоматической починки на СТО
local autoSTOExit_imgui = imgui.ImBool(mainIni.config.autostoexit) -- CB для автоматического выхода с СТО после починки
local autoSTOKolvo_imgui = imgui.ImInt(mainIni.config.autostokolvo) -- Строка с числовым значение минимального количества ХП для починки авто
local pass_buffer_imgui = imgui.ImBuffer(256) -- Строка для хранения пароля
pass_buffer_imgui.v = tostring(mainIni.config.password) -- Заполняем строку паролем из конфига
local google_buffer_imgui = imgui.ImBuffer(256) -- Строка для 2FA
google_buffer_imgui.v = tostring(mainIni.config.google) -- Заполняем строку 2FA из конфига
local pass_show_imgui = imgui.ImBool(false) -- CB показывать ли пароль (по умолчанию пароль закрыт звёздочками (*))
local pass_show = false -- Используется в совокупности с pass_show_imgui
local google_show_imgui = imgui.ImBool(false) -- CB показывать ли 2FA (по умолчанию 2FA закрыт звёздочками (*))
local google_show = false -- Используется в совокупности с google_show_imgui
local isChangingButton = false -- Если игрок меняет кнопку закрытия\открытия ТС, то кнопка меняет своё название с "Изменить кнопку" на "Пожалуйста нажмите требуемую кнопку"

-- Таблица с информацией о командах
local commands = {
    -- Основное
    ["/luna"] = { -- Меню скрипта
        action = function()
            lua_thread.create(function()
                show_main_window.v = not show_main_window.v
            end)
        end
    },
    ["/lunard"] = { -- Перезагрузка скрипта
        action = function()
            lua_thread.create(function()
                thisScript():reload()
            end)
        end
    },
    ["/lunabb"] = { -- Отгрузка скрипта
        action = function()
            lua_thread.create(function()
                sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}Скрипт {FF0000}[Отгружен]", 0xccccccAA)
                thisScript():unload()
            end)
        end
    },
    ["/lunacf"] = { -- Сброс конфига (Ленивый способ в виде удаления конфига и перезагрузки скрипта)
        action = function()
            lua_thread.create(function()
                os.remove(getWorkingDirectory().."\\config\\Luna Helper.ini")
                inicfg.load(mainIni, "..\\config\\Luna Helper.ini")
                thisScript():reload()
            end)
        end
    },
}
-- Функции
function main() -- Основная функция, подгружаемая при загрузке скрипта
    while not isSampAvailable() do wait(0) end
    local ip, port = sampGetCurrentServerAddress()
    if ip ~= "146.59.94.128" and port ~= 7777 then -- Pears Project
        thisScript():unload() -- Отгружаем скрипт, если юзер заходит на другой сервер
        return 0
    end
    if not doesFileExist("moonloader/config/Luna Helper.ini") then -- Если нет конфига, пишем об этом
        sampAddChatMessage("{00ff00}* {cd70ff}[Luna Helper] {FFFFFF}Вы запускаете скрипт в первый раз. Конфиг был успешно создан!", 0xccccccAA)
    end
    sampAddChatMessage("{00ff00}* {cd70ff}[Luna Helper] {FFFFFF}Версия скрипта {cccccc}" .. lunaversion .. " {ffffff}успешно загружена {FF9000}[ /luna ]", 0xccccccAA)
    inicfg.save(mainIni, "Luna Helper.ini") -- При запуске скрипта сохраняем конфиг (Если нет конфига, он создаётся в таком случае)

    while true do
        wait(0) -- Раз в 0 сек функции ниже вызываются, то есть по кд
        imgui.Process = show_main_window.v
        if show_main_window.v == false then
            pass_show, pass_show_imgui.v, google_show, google_show_imgui.v = false, false, false, false
        end
        pass_buffer_imgui.v = tostring(mainIni.config.password)
        google_buffer_imgui.v = tostring(mainIni.config.google)
        autoSTOKolvo_imgui.v = mainIni.config.autostokolvo
        TextdrawSTO() -- Текстдрав СТО
        AutoLock() -- Открытие и закрытии тс при нажатии на L
    end
end

function pressNewButton() -- "Венец моего творения". Функция, которая устанавливает новую клавишу для закрытия\открытия ТС.
    local buff = true
    while buff do -- постоянно парсим массив vkeys, для обнаружения новой нажатой кнопки
        wait(0) -- это база
        if not buff then -- короче я хз, но без этой штуки он не хочет заканчивать функцию, а значит вся её идея ломается
            break
        else 
            for i, value in pairs(vkeys) do -- парсим массив с кнопками
                if isKeyJustPressed(value) then -- если кнопка была нажата, то сохраняем её в маинИни + сохраняем в файл. Парсится вёс очь быстро, так что проблем с этим нету.
                    mainIni.config.lockvehicle_key = value
                    SaveIni()
                    buff = false
                end
            end
        end
    end
    -- Разблокируем игроку движение, курсор и поменяем название кнопки на "Выбрать клавишу"
    imgui.LockPlayer = false 
    imgui.ShowCursor = true
    isChangingButton = false
end

function genCode(skey) -- Генерация кода по GAuth (2FA)
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

function SaveIni() -- Синтаксический сахар
    inicfg.save(mainIni, 'Luna Helper.ini')
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
        if mainIni.config.login and string.find(text, "Поиск аккаунта..") or string.find(text, "Загрузка аккаунта..") then
            return false -- Убираем диалог поиск и загрузка аккаунта, если автологин включен
        end
    end
    if id == 220 then
        if mainIni.config.login and string.find(text, "Привет,") then 
            sampSendDialogResponse(220, 1, 65535, "") -- Нажимаем далее в диалоге где пишет привет нажми Ентер
            return false -- Убираем диалог
        end
    end
    if id == 1 and mainIni.config.login and string.find(title, "Авторизация") then -- Автоввод пароля если автологин включен
        if mainIni.config.password == 'nopassword' then
            return
        else
            sampSendDialogResponse(1, 1, 65535, mainIni.config.password)
            return false -- Убираем диалог
        end
    end
    if id == 798 and mainIni.config.login and string.find(title, "Авторизация") then -- Автоввод 2FA если автологин включен
        if mainIni.config.google == 'nogoogle' then
            return
        else
            local code = genCode(mainIni.config.google) -- Генерация 2FA кода
            sampSendDialogResponse(798, 1, 65535, code) -- Подставляем код в ответ
            return false -- Убираем диалог
        end
    end

    -- Автозаправка
    if id == 484 and mainIni.config.autofuel and string.find(title, "Заправка") then
        if noFuel then -- На всякий проверочка если денег нет или ещё какая-то ошибка, чтобы не флудило диалог
            noFuel = false -- Сразу ставим false чтобы если починилось то сработало всё
            return false
        end
        local liters = text:match("Для полного бака вам требуется: (%d+) литров")
        if liters then -- Если получено максимальное кол-во литров, которое можно заправить
            sampSendDialogResponse(484, 1, 65535, liters) -- Заправляем на максимальное кол-во литров
            noFuel = true -- На всякий ставим проверку мол денег нет или ещё какая-то ошибка
            return false -- Сразу же убираем диалог, чтобы не раздражал
        end
    end
    if id == 1700 and mainIni.config.autofuel and string.find(text, "Я заправляю") then
        noFuel = false -- Удачная заправка, возвращаем false
        return false -- Сразу же убираем диалог, чтобы не раздражал
    end

    -- Автопочинка в Автосервисе
    if id == 562 and mainIni.config.autosto and string.find(title, "Обслуживание") then -- Автопочинка
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
    if id == 1700 and mainIni.config.autosto and string.find(text, "В автосервисе не хватает рем комплектов") then -- Если ремки закончились в СТО 
        sampAddChatMessage("{ff0000}* {cd70ff}[Luna Helper] {FFFFFF}Автопочинка не сработала. В автосервисе закончились рем комплекты.", 0xccccccAA)
        ExitSTO() -- Выходим с СТО если включена функция автовыхода с сто после автопочинки
        return false -- Убираем диалог
    end
    if id == 1700 and mainIni.config.autosto and string.find(text, "Вам не хватает денег") then -- Если денег нет на починку
        sampAddChatMessage("{ff0000}* {cd70ff}[Luna Helper] {FFFFFF}Автопочинка не сработала. Вам не хватает денег.", 0xccccccAA)
        ExitSTO() -- Выходим с СТО если включена функция автовыхода с сто после автопочинки
        return false -- Убираем диалог
    end
    if id == 1700 and mainIni.config.autosto and string.find(text, "Вы выехали из автосервиса") then -- Скип диалога
        return false
    end
end

function apply_custom_style() -- Наводим красоту
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

function onWindowMessage(msg, wparam, lparam) -- Ивент, в котором мы делаем так, чтобы при открытом ImGui и нажатии на ескейп нас не кидало в меню игры + закрывалось окно imgui
    if msg == 0x100 or msg == 0x101 then
        if (wparam == vkeys.VK_ESCAPE and show_main_window.v) and not isPauseMenuActive() then
            consumeWindowMessage(true, false)
            if msg == 0x101 then
                show_main_window.v = false
            end
        end
    end
end

function imgui.OnDrawFrame() -- Ивент, который срабатывает каждый фрейм игры
    if show_main_window.v then -- если true, то показываем окно
        local sw, sh = getScreenResolution() -- берём разрешение окна 
        local btn_size = imgui.ImVec2(-0.1, 0) -- размер кнопок (-0.1 означает, что по краям кнопки будет пустое пространство, например ##[Кнопка 1]##, где # - -0.1)
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) -- Позиция окна будет посередине. Чё делает imgui.Cond.FirstUseEver я хз
        imgui.SetNextWindowSize(imgui.ImVec2(650, 450), imgui.Cond.FirstUseEver) -- Размер окна. Подбирал с помощью проб и ошибок
        imgui.Begin(u8'Luna Helper ' .. lunaversion, show_main_window) -- Название окна + show_main_window, чтобы появился крестик сверху окошка
        if imgui.Checkbox(u8'Автологин', autoLogin_imgui) then -- Кнопка с галочкой
            mainIni.config.login = autoLogin_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
        end
        if imgui.Checkbox(u8'Автозаправка', autoFuel_imgui) then -- Кнопка с галочкой
            mainIni.config.autofuel = autoFuel_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
        end
        if imgui.Checkbox(u8'Автопочинка', autoSTO_imgui) then -- Кнопка с галочкой
            mainIni.config.autosto = autoSTO_imgui.v
            if autoSTO_imgui.v == false then  -- Если Автопочинка отключена, то и автовыход с неё мы тоже вырубаем
                mainIni.config.autostoexit = false 
                autoSTOExit_imgui.v = false
            end
            inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
        end
        if autoSTO_imgui.v then -- Если автопочинка включена, то только в таком случае показываем CB на автовыход с СТО  
            imgui.NewLine()
            imgui.SameLine(30.0, 0.0) -- отступы красивые
            if imgui.Checkbox(u8'Автовыход с СТО после починки', autoSTOExit_imgui) then
                mainIni.config.autostoexit = autoSTOExit_imgui.v
                inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
            end
        end
            
        if imgui.Checkbox(u8'Открыть/Закрыть транспорт (L)', lockPlayer_imgui) then -- Кнопка с галочкой
            mainIni.config.lockvehicle = lockPlayer_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
        end
        if lockPlayer_imgui.v then -- Если активированна опция по закрытию\открытию по кнопке, то показываем дополнительные настройки
            imgui.NewLine()
            imgui.SameLine(30.0, 0.0) -- отступы красивые
            imgui.Text(u8'Текущая кнопка: '..vkeys.id_to_name(mainIni.config.lockvehicle_key)) -- Просто текст для понимания ситуации + vkeys.id_to_name, с помощью которого ищем человеческого название кнопки
            if not isChangingButton then -- Если мы ещё не меняем кнопку, то выводим стандартную кнопку
                if imgui.Button(u8'Изменить клавишу', btn_size) then -- При нажатии блокируем движение игрока и прячем курсор, чтобы он не начал шалить
                    isChangingButton = true
                    imgui.LockPlayer = true
                    imgui.ShowCursor = false
                    potok = lua_thread.create(pressNewButton) -- Отдельный поток, т.к. требуется while true
                end
            else
                if imgui.Button(u8'Нажмите на требуемую клавишу', btn_size) then -- Кнопка появляется во время выбора клавиши
                   return
                end
            end
        end
        
        imgui.Text(u8'Мин. количество ХП для починки: ') -- Просто текст
        imgui.SameLine(0.0, -1.0) -- делаем так, чтобы след. строка не перенеслась на новую строчку и как бы "дополняем" наш текст
        if imgui.InputInt(' ##3', autoSTOKolvo_imgui) then -- условие будет срабатывать при изменении числа минимального ХП для починки
            mainIni.config.autostokolvo = autoSTOKolvo_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
        end

        imgui.NewLine()

        imgui.Text(u8'Пароль:\t\t\t\t\t\t\t\t ') -- АХАХАХАХАХАХ найс костыль создал))) (чтобы ввод пароля и 2FA был на одном уровне +-)
        imgui.SameLine(0.0, -1.0) -- "Дополняем" текст, а не переносимся на новую строку
        if imgui.InputText(' ##1', pass_buffer_imgui, pass_show and 0 or imgui.InputTextFlags.Password) then -- 1) условие будет срабатывать при изменении текста. 2) Если pass_show = true, то мы показываем пароль (так если 0) иначе кидаем флаг, который заставляет символы измениться на *
            mainIni.config.password = pass_buffer_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
        end

        imgui.Text(u8'Код 2FA (аутентификация): ') -- just text
        imgui.SameLine(0.0, -1.0) -- "Дополняем" текст, а не переносимся на новую строку
        if imgui.InputText(' ##2', google_buffer_imgui, google_show and 0 or imgui.InputTextFlags.Password) then -- 1) условие будет срабатывать при изменении текста. 2) Если google_show = true, то мы показываем 2FA (так если 0) иначе кидаем флаг, который заставляет символы измениться на *
            mainIni.config.google = google_buffer_imgui.v
            inicfg.save(mainIni, "Luna Helper.ini") -- Сохраняем конфиг
        end
        if imgui.Checkbox(u8'Показать пароль', pass_show_imgui) then -- Кнопка с галочкой
            pass_show = pass_show_imgui.v
        end
        imgui.SameLine(0.0, -1.0) -- чтобы расположить 2 CB рядышком
        if imgui.Checkbox(u8'Показать 2FA', google_show_imgui) then -- Кнопка с галочкой
            google_show = google_show_imgui.v
        end
        
        imgui.NewLine() -- чтобы пропустить строку (для красоты)
        if imgui.Button(u8'Перезагрузить скрипт', btn_size) then -- Кнопка
            showCursor(false)
            thisScript():reload()
        end
        if imgui.Button(u8'Отгрузить скрипт', btn_size) then -- Кнопка
            showCursor(false)
            sampAddChatMessage("* {cd70ff}[Luna Helper] {FFFFFF}Скрипт {FF0000}[Отгружен]", 0xccccccAA)
            thisScript():unload()
        end
        if imgui.Button(u8'Сбросить конфиг', btn_size) then -- Кнопка
            showCursor(false)
            os.remove(getWorkingDirectory().."\\config\\Luna Helper.ini")
            inicfg.load(mainIni, "..\\config\\Luna Helper.ini")
            thisScript():reload()
        end

        imgui.End()
    end
end


function TextdrawSTO() -- Автопочинка текстдрав
    if mainIni.config.autosto then
        local buttonSTO = 13 -- ИД кнопки
        local textSTO = 16 -- ИД текста
        local autostokolvo = tonumber(mainIni.config.autostokolvo) -- Получаем с конфига хп установленное
        if isCharInAnyCar(PLAYER_PED) then
            local car = storeCarCharIsInNoSave(PLAYER_PED) -- Проверка на тс
            local health = getCarHealth(car) -- Проверка хп тс
            if health <= autostokolvo then -- Проверка хп, если у тс меньше или равно значения с конфига чиним
                if sampTextdrawIsExists(buttonSTO) 
                and sampTextdrawIsExists(textSTO) and sampTextdrawGetString(textSTO) == "O—cћy›њўa®њe" -- Проверка текста (Обслуживание)
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
    if mainIni.config.autostoexit then
        local buttonexit = 12 -- ИД кнопки выхода с автосервиса
        local textexit = 20 -- ИД текста выхода с автосервиса
        if sampTextdrawIsExists(buttonexit) and sampTextdrawIsExists(textexit) 
        and sampTextdrawGetString(textexit) == "‹Ёxoљ" then -- Проверка текста (Выход)
            sampSendClickTextdraw(buttonexit) -- Кликаем на текстдрав
        end
    end
end

function AutoLock() -- Открытие/Закрытие тс через L
    if mainIni.config.lockvehicle then
        if isKeyJustPressed(mainIni.config.lockvehicle_key) and not sampIsChatInputActive() 
        and not sampIsDialogActive() and not isSampfuncsConsoleActive() then -- Проверка чтобы не срабатывала если чат открыт и прочее
            sampSendChat("/lock") -- Если всё ок, пишем в чат вместо игрока /lock
        end
    end
end