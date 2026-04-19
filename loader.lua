-- [[ Artly Hub: Universal Loader ]] --

local PlaceId = game.PlaceId
local MainURL = "https://raw.githubusercontent.com/Egor-pixel-dev/Artly/refs/heads/main/"

-- Списки ID для сверки
local Lobbies = {
    [11684369582] = "IWTTG Lobby",   -- Твой ID лобби IWTTG
    [6516141723] = "DOORS Lobby"    -- Лобби Дорса
}

local Games = {
    [4139766490] = "IWTTG Game",
    [103066657869726] = "Build & Survive",
    -- Для Дорса (когда зашел в саму игру) ID меняется, добавь его сюда:
    [0000000000] = "DOORS Game" 
}

-- Функция уведомления
local function Notify(title, msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = msg,
        Duration = 5
    })
end

-- ЛОГИКА ПРОВЕРКИ
if Lobbies[PlaceId] then
    -- Если мы в лобби
    _game = "lobby"
    Notify("Artly Hub", "Joined Game Lobby: " .. Lobbies[PlaceId])
    print("Artly Hub | Detected Lobby")

elseif Games[PlaceId] then
    -- Если мы в основной игре
    _game = Games[PlaceId]
    Notify("Artly Hub", "Loading script for " .. _game)
    
    -- Загружаем основной чит по PlaceId (как у тебя была задумка)
    loadstring(game:HttpGet(MainURL .. PlaceId .. ".lua"))()

else
    -- Если зашел в левую игру
    Notify("Artly Hub Error", "Wrong Game! This game is not supported.")
    warn("Artly Hub | Unauthorized Game ID: " .. PlaceId)
end
