local GlobalEvents = require("LuaScripts/GlobalEvents")
local uiManager = require("LuaScripts/ui/UI_Manager")
local gameAudio = require "LuaScripts/Audio"
local world     = require "LuaScripts/World"

---@class UiEndgame : UiScreen
local Ui = {}

Ui.screenName = "Endgame"


--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function (instanceRoot)

end

---@param instanceRoot UIElement
---@param dataPassed EndGameScreenData
Ui.Show = function (instanceRoot, dataPassed)

    uiManager.HideUI("Game")
    instanceRoot:SetVisible(true)

    local pointsText = instanceRoot:GetChild("winnerText", true)

    local winnerName = dataPassed.winnerName

    if not winnerName then
        winnerName = "nameless"
    end

    pointsText.text = "WINNER: " .. winnerName

    gameAudio.PlayOneShotSoundWithFrequency("Sounds/rock/arrival.ogg", 1.0, 22050, false)

    coroutine.start(function ()
        coroutine.sleep(5.0)
        world.Cleanup()
        uiManager.HideUI("Endgame")
        uiManager.ShowUI("MainMenu")
    end)

end

return Ui