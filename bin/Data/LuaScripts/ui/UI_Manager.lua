-- handles opening UI setups that should only be created once. Stores UIs that have already been loaded, hidden or not

-- should receive calls like "open splash screen"; then, it should check if the target screen already exists in the cache.
-- If not, it should load it, store it and return it

---@class GameUiManager
local GameUi = {}

GameUi.StoredUis = {}

-- if necessary, loads, then returns the specified UI. The Ui must have already been added in the StoredUis list
---@param UIname string
---@return UIElement|nil
function GameUi.GetUI(UIname)
    local targetUi = GameUi.StoredUis[UIname]
    if targetUi ~= nil then
        if targetUi.attachedInstance ~= nil then
            return targetUi.attachedInstance
        else
            --load the ui and try again
            GameUi.LoadUI(UIname)
            return GameUi.GetUI(UIname)
        end
    end

    return nil
end


---should display the target Ui, optionally using the provided sentData table to customize the ui's actions and elements
---@param UIname string
---@param sentData? table
function GameUi.ShowUI(UIname, sentData)
    local targetUi = GameUi.StoredUis[UIname]
    if targetUi ~= nil then
        if targetUi.attachedInstance == nil then
            GameUi.LoadUI(UIname)
        end
    else
        Log:Write(LOG_WARNING, "UIManager: attempted to show undeclared UI " .. UIname)
    end

    targetUi.handlerFile.Show(GameUi.GetUI(UIname), sentData)
end

---should disable display of the target UI (also attempts to load the UI)
---@param UIname string
function GameUi.HideUI(UIname)
    GameUi.GetUI(UIname):SetVisible(false)
end

-- loads resources for the specified UI and creates a disabled instance of it.
-- stores the created UI in the attachedInstance var.
-- The Ui must have already been added in the StoredUis list
---@param UIname string
function GameUi.LoadUI(UIname)
    local targetUi = GameUi.StoredUis[UIname]
    if targetUi ~= nil then
        if targetUi.attachedInstance ~= nil then
            return targetUi.attachedInstance
        else
            targetUi.attachedInstance = ui:LoadLayout(cache:GetResource("XMLFile", targetUi.uiFilePath))
            if targetUi["isSetup"] ~= true then
                targetUi.handlerFile.Setup(targetUi.attachedInstance)
                targetUi["isSetup"] = true
            end
            targetUi.attachedInstance:SetVisible(false) -- apparently equal to "setactive false" in unity
            ui.root:AddChild(targetUi.attachedInstance)
        end
    end
end


-- sets/overrides stored ui definitions with the ones defined in the provided array
---@param definitionsArr UiDefinition[]
function GameUi.AddUiDefinitions (definitionsArr)
    for key, value in pairs(definitionsArr) do
        --Log:Write(LOG_INFO, "added definition " .. value.uiFilePath)
        GameUi.StoredUis[key] = value
    end
end

return GameUi
