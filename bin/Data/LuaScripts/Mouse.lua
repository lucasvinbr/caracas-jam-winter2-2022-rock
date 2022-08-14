local mouseConfig = {}

-- handles mouse
mouseConfig.UseMouseMode_ = MM_FREE

-- If the user clicks the canvas, attempt to switch to relative mouse mode on web platform
local function HandleMouseModeRequest(eventType, eventData)
    if console ~= nil and console.visible then
        return
    end

    if input.mouseMode == MM_ABSOLUTE then
        input.mouseVisible = false
    elseif UseMouseMode_ == MM_FREE then
        input.mouseVisible = true
    end

    input.mouseMode = UseMouseMode_
end

-- If the user clicks the canvas, attempt to switch to relative mouse mode on web platform
local function HandleMouseModeChange(eventType, eventData)
    MouseLocked = eventData["MouseLocked"]:GetBool()
    input.mouseVisible = not MouseLocked
end

---@param mode MouseMode
function mouseConfig.SetMouseMode(mode)
    UseMouseMode_ = mode

    if UseMouseMode_ == MM_FREE then
        input.mouseVisible = true
    end

    input.mouseMode = UseMouseMode_

    if UseMouseMode_ ~= MM_ABSOLUTE then
        if console ~= nil and console.visible then
            input:SetMouseMode(MM_ABSOLUTE, true)
        end
    end

    HandleMouseModeRequest()
end

function mouseConfig.SetupMouseEvents()
    SubscribeToEvent("MouseButtonDown", HandleMouseModeRequest)
    SubscribeToEvent("MouseModeChanged", HandleMouseModeChange)
end


return mouseConfig
