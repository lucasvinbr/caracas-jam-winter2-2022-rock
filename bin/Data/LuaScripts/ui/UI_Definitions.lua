
---@class UiDefinition
---@field uiFilePath string
---@field attachedInstance UIElement
local MainMenu = { 
    uiFilePath = "UI/rock/screen_title.xml",
    handlerFile = require("LuaScripts/ui/screens/UI_MainMenu")
 }

---@type UiDefinition[]
local definitions = {
    MainMenu = MainMenu,
    PopupGeneric = { uiFilePath = "UI/rock/overlay_popup.xml" },
    PopupInput = {
        uiFilePath = "UI/rock/generic_input_overlay.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Popup_Input")
    },
    Endgame = { 
        uiFilePath = "UI/rock/screen_endgame.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Endgame")
    },
    Credits = { 
        uiFilePath = "UI/rock/screen_credits.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Credits")
    },
    HowTo = { 
        uiFilePath = "UI/rock/screen_howto.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Credits")
    },
    Loading = { 
        uiFilePath = "UI/rock/screen_loading.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Loading")
    },
    Game = { 
        uiFilePath = "UI/rock/screen_game.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Game")
    },
}


-- extra emmylua ui-related definitions...

---@class PopupDisplayData
---@field title string
---@field prompt string
---@field buttonInfos PopupButtonInfo[]

---@class InputPopupDisplayData : PopupDisplayData
---@field inputFieldInitialValue string

---@class PopupButtonInfo
---@field buttonText string
---@field buttonAction function
---@field closePopupOnClick boolean

---@class EndGameScreenData
---@field winningPlayer Player

return definitions