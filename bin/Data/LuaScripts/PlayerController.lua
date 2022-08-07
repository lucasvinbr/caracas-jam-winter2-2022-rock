---@class PlayerController : LuaScriptObject


-- Character script object class
---@type PlayerController
PlayerController = ScriptObject()

PlayerController.__index = PlayerController

function PlayerController:Start()
    self.playerScript = self.node:GetScriptObject("Player") --[[@as Player]]


    self.wantsToAttack = false
    self.moveDir = Vector2.ZERO

end

function PlayerController:Update(timeStep)

    if CurGameState ~= GAMESTATE_PLAYING then
        return
    end

    self.moveDir = Vector2.ZERO
    if input:GetKeyDown(KEY_LEFT) or input:GetKeyDown(KEY_A) then
        self.moveDir = self.moveDir + Vector2.LEFT
    end
    if input:GetKeyDown(KEY_RIGHT) or input:GetKeyDown(KEY_D) then
        self.moveDir = self.moveDir + Vector2.RIGHT
    end

    if input:GetKeyDown(KEY_UP) or input:GetKeyDown(KEY_W) then
        self.moveDir = self.moveDir + Vector2.UP
    end
    if input:GetKeyDown(KEY_DOWN) or input:GetKeyDown(KEY_S) then
        self.moveDir = self.moveDir + Vector2.DOWN
    end

    if self.moveDir ~= Vector2.ZERO then
        self.moveDir:Normalize()
    end

    self.wantsToAttack = false
    if input:GetKeyPress(KEY_SPACE) then
        self.wantsToAttack = true
    end

    self.playerScript:UpdateControls(self.moveDir, self.wantsToAttack)

end