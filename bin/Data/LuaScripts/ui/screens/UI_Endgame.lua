local GlobalEvents = require("LuaScripts/GlobalEvents")
local uiManager    = require("LuaScripts/ui/UI_Manager")
local gameAudio    = require "LuaScripts/Audio"
local world        = require "LuaScripts/World"

---@class UiEndgame : UiScreen
local Ui = {}

Ui.screenName = "Endgame"


--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function(instanceRoot)

end

---@param instanceRoot UIElement
---@param dataPassed EndGameScreenData
Ui.Show = function(instanceRoot, dataPassed)

    instanceRoot:SetVisible(true)

    local endgameText = instanceRoot:GetChild("winnerText", true)
    endgameText:SetColor(C_TOPLEFT, Color.WHITE)

    local winner = dataPassed.winningPlayer

    local winnerName = winner.charData.name

    if not winnerName then
        winnerName = "nameless"
    end

    endgameText.text = "GAME SET!"

    gameAudio.PlayOneShotSoundWithFrequency("Sounds/rock/arrival.ogg", 1.0, 22050, false)

    for _, plyr in ipairs(world.PlayerScripts) do
        plyr:ForceAnim("idle")
    end

    coroutine.start(function()
        -- fade to black
        for i = 1, 10, 1 do
            local colorValue = i / 10
            world.fadeSprite:SetColor(Color(0, 0, 0, colorValue))
            coroutine.sleep(0.05)
        end

        -- hide text, wait a little then show winner's name and sprite!
        coroutine.sleep(0.95)
        endgameText.text = ""
        coroutine.sleep(1.05)
        endgameText.text = "WINNER: " .. winnerName
        endgameText:SetColor(C_TOPLEFT, winner.playerColor)

        winner.animatedSprite:SetLayer(SPRITELAYER_ENDGAME_FADE + 1)
        winner:ForceAnim("rock")

        coroutine.sleep(4.0)
        world.Cleanup()
        uiManager.HideUI("Endgame")
        uiManager.ShowUI("MainMenu")
    end)

end

return Ui
