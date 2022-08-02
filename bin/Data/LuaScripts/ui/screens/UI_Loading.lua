local uiManager = require("LuaScripts/ui/UI_Manager")
local world = require "LuaScripts/World"

---@class UiLoading: UiScreen
local Ui = {}

Ui.screenName = "Loading"


local cachedInstanceRoot = nil


--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function (instanceRoot)
    cachedInstanceRoot = instanceRoot

end

Ui.LoadingDone = function ()
    cachedInstanceRoot:SetVisible(false)

    log:Write(LOG_DEBUG, "loading done!")
    world.DoneSettingUp = true
    Scene_.updateEnabled = true
    -- StartMusic()

    CurGameState = GAMESTATE_PLAYING
    uiManager.ShowUI("Game")
end

---@param instanceRoot UIElement
---@param dataPassed table
Ui.Show = function (instanceRoot, dataPassed)
    instanceRoot:SetVisible(true)

    world.DoneSettingUp = false

    SetupGameMatch()

    Ui.LoadingDone()

end

return Ui