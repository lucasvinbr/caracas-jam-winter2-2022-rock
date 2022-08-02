local uiManager = require "LuaScripts/ui/UI_Manager"
local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"

---@class Player : LuaScriptObject
---@field timeBar ProgressBar

local JUMP_FORCE = 7.0
local MOVE_FORCE = 0.8
local INAIR_MOVE_FORCE = 0.02
local BRAKE_FORCE = 0.2
local MOVE_SPEED = 2.0
local VERTICAL_MOVESPEED_FACTOR = 0.8

local TIME_BEFORE_ROCKING = 2.0

-- Character script object class
---@type Player
Player = ScriptObject()

Player.__index = Player

function Player:Start()
    self.canCountTime = false
    self.canMove = true

    self.timeBar = nil

    self.isRocking = false
    self.idleTime = 0.0

    self.spriteNode = self.node:CreateChild("playerSpriteNode")

    self.animatedSprite = self.spriteNode:CreateComponent("AnimatedSprite2D")
    self.animatedSprite.animationSet = cache:GetResource("AnimationSet2D", "Urho2D/rock/player.scml")
    self.animatedSprite.animation = "idle"
    self.animatedSprite:SetLayer(4)

    ---@type RigidBody2D
    self.body = self.node:CreateComponent("RigidBody2D")
    self.body:SetGravityScale(0.0)
    self.body.bodyType = BT_DYNAMIC
    self.body.allowSleep = false

    ---@type CollisionCircle2D
    self.colshape = self.node:CreateComponent("CollisionCircle2D")
    self.colshape.radius = 1.1 -- Set shape size
    self.colshape.friction = 0.0 -- Set friction
    self.colshape.restitution = 0.1 -- Slight bounce
    self.colshape:SetCategoryBits(COLMASK_PLAYER)

    self.node:SetScale(3.0)

    log:Write(LOG_DEBUG, self.node.worldPosition:ToString())
end

function Player:Update(timeStep)

    if CurGameState ~= GAMESTATE_PLAYING then
        return
    end

    local node = self.node

    -- Set direction
    ---@type Vector3
    local moveDir = Vector3.ZERO -- Reset
    local speedX = Clamp(MOVE_SPEED, 0.4, MOVE_SPEED)
    local speedY = speedX

    if input:GetKeyDown(KEY_LEFT) or input:GetKeyDown(KEY_A) then
        moveDir = moveDir + Vector3.LEFT * speedX
        self.animatedSprite.flipX = true -- Flip sprite (reset to default play on the X axis)
    end
    if input:GetKeyDown(KEY_RIGHT) or input:GetKeyDown(KEY_D) then
        moveDir = moveDir + Vector3.RIGHT * speedX
        self.animatedSprite.flipX = false -- Flip sprite (flip animation on the X axis)
    end

    if not moveDir:Equals(Vector3.ZERO) then
        speedY = speedX * VERTICAL_MOVESPEED_FACTOR
    end

    if input:GetKeyDown(KEY_UP) or input:GetKeyDown(KEY_W) then
        moveDir = moveDir + Vector3.UP * speedY
    end
    if input:GetKeyDown(KEY_DOWN) or input:GetKeyDown(KEY_S) then
        moveDir = moveDir + Vector3.DOWN * speedY
    end

    -- Move
    if not moveDir:Equals(Vector3.ZERO) and self.canMove then
        node:Translate(moveDir * timeStep)
        self.idleTime = 0.0
        self.isRocking = false
    else
        self.idleTime = self.idleTime + timeStep
        if not(self.isRocking) and self.idleTime >= TIME_BEFORE_ROCKING then
            self.isRocking = true
        end
    end

    -- animation...
    if self.isRocking then
        self.animatedSprite:SetAnimation("rock")
    else
        self.animatedSprite:SetAnimation("idle")
    end

end

function Player:HandleCollisionStart(eventType, eventData)

    if CurGameState ~= GAMESTATE_PLAYING then return end

    local velocity = self.body.linearVelocity:Length()

    gameAudio.PlayOneShotSoundWithFrequency(hitSounds[RandomInt(#hitSounds) + 1],
     1.0,
      20050 + Lerp(0, 20000, velocity / 20.0),
       true,
        self.node)
end
