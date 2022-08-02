local world = require "LuaScripts/World"
local uiManager = require "LuaScripts/ui/UI_Manager"
---@class Watcher : LuaScriptObject
---@field eyesNode Node
---@field desiredRotation Quaternion
---@field model AnimatedModel
---@field animController AnimationController

local MIN_INTERVAL_CHANGEVIEW = 8.0
local MAX_INTERVAL_CHANGEVIEW = 14.0

-- Character script object class
---@type Watcher
Watcher = ScriptObject()

Watcher.__index = Watcher

function Watcher:Start()
    self.canMove = true

    self.eyesNode = self.node:GetChild("watcher_eyesPoint")

    self.timeSinceLastViewChange = MAX_INTERVAL_CHANGEVIEW
    self.timeNextViewChange = Random(MIN_INTERVAL_CHANGEVIEW, MAX_INTERVAL_CHANGEVIEW)

    self.desiredRotation = self.eyesNode.rotation

    self.model = self.node:GetComponent("AnimatedModel")
    self.animController = self.node:GetComponent("AnimationController")

    self.model:SetEnabled(false)
    self:SubscribeToEvent(self.node, "NodeCollisionStart", "Watcher:HandleCollisionStart")
end

function Watcher:Update(timeStep)

    self.timeSinceLastViewChange = self.timeSinceLastViewChange + timeStep

    if self.canMove and self.timeSinceLastViewChange > self.timeNextViewChange then
        self.timeSinceLastViewChange = 0.0
        self.timeNextViewChange = Random(MIN_INTERVAL_CHANGEVIEW, MAX_INTERVAL_CHANGEVIEW)
        self.desiredRotation:FromAngleAxis(Random(0, 360), Vector3.UP)
    end

    if self.canMove then
        self.eyesNode.rotation = self.eyesNode.rotation:Slerp(self.desiredRotation, timeStep)

        GameCameraNode.worldPosition = self.eyesNode.worldPosition
        GameCameraNode.worldRotation = self.eyesNode.worldRotation
    end


end

function Watcher:HandleCollisionStart(eventType, eventData)

    if CurGameState ~= GAMESTATE_PLAYING then return end

    local collidingNode = eventData["OtherNode"]:GetPtr("Node") --[[@as Node]]

    log:Write(LOG_DEBUG, "someone got the watcher")
    world.FreezeAllPlayers()
    self.canMove = false
    self.model:SetEnabled(true)
    self.animController:Play("Models/mballs/Genericus/test_stand_idle_crazyarms.ani", 0, true)
    GameCameraNode:Translate(Vector3(5.0, 5.0, 5.0))
    GameCameraNode:LookAt(collidingNode.worldPosition)
    uiManager.ShowUI("Endgame", collidingNode:GetName())
end
