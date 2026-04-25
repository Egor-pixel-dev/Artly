-- [[ Artly Hub: Advanced Universal Loader ]] --

local PlaceId = game.PlaceId
local StarterGui = game:GetService("StarterGui")

-- 1. СПИСОК ЛОББИ (Сюда пишем ID, где просто уведомление)
local LobbyList = {
    [11684369582] = "IWTTG Lobby",
    [6516141723] = "Doors Lobby"
}

-- 2. СПИСОК ИГР (Сюда пишем ID, где должен грузиться чит)
local GameList = {
    [103066657869726] = "Build & Survive",
    [18468631822] = "IWTTG Game",
    [6833009714] = "Doors Game" -- Замени на реальный ID игры Doors
}

local function Notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

-- Основная логика проверки
local isLobby = LobbyList[PlaceId]
local isGame = GameList[PlaceId]

if isLobby then
    _game = "lobby"
    Notify("Artly Hub", "Joined Lobby: " .. isLobby)
elseif isGame then
    _game = isGame
    Notify("Artly Hub", "Game Detected! Loading script...")
    -- Загружаем основной скрипт по ID
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Egor-pixel-dev/Artly/refs/heads/main/" .. PlaceId .. ".lua"))()
else
    Notify("Artly Hub", "Wrong Game! ID: " .. PlaceId)
    return
end

-- МАГИЯ ДЛЯ ПЕРЕЗАПУСКА (queue_on_teleport)
-- Этот кусок заставляет лоадер запускаться заново после телепорта
local teleportCode = [[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Egor-pixel-dev/Artly/refs/heads/main/loader.lua"))()
]]

local queue_on_teleport = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or queue_on_teleport

if queue_on_teleport then
    queue_on_teleport(teleportCode)
end
