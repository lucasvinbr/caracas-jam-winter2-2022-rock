local uiManager = require "LuaScripts/ui/UI_Manager"
local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"

---@class Player : LuaScriptObject
---@field timeBar ProgressBar
---@field body RigidBody2D
---@field colshape CollisionCircle2D
---@field spriteNode Node
---@field animatedSprite AnimatedSprite2D

local MOVE_FORCE = 0.8
local BRAKE_FORCE = 0.2
local MOVE_SPEED = 40.0
local VERTICAL_MOVESPEED_FACTOR = 0.65
local ATTACK_DURATION = 0.3
local ATTACK_TIME_BEFORE_HIT = 0.15


local TIME_BEFORE_ROCKING = 2.0

local PLAYERSTATE_IDLE = 0
local PLAYERSTATE_MOVING = 1
local PLAYERSTATE_ROCKING = 2
local PLAYERSTATE_ATTACKING = 3

local ROCKING_TIME_TO_WIN = 8.0


-- Character script object class
---@type Player
Player = ScriptObject()

Player.__index = Player

function Player:Start()
    self.canCountTime = false
    self.canMove = true

    self.timeBar = nil

    self.wantsToAttack = false
    self.moveDir = Vector2.ZERO

    self.curPlayerState = PLAYERSTATE_IDLE
    self.attackIsComplete = false

    -- counter for mutually exclusive actions, like idling and attacking
    self.actionTimeElapsed = 0.0

    self.timeSinceLastAttack = 1.0

    self.body = self.node:CreateComponent("RigidBody2D")
    self.body:SetGravityScale(0.0)
    self.body:SetLinearDamping(5.0)
    self.body.bodyType = BT_DYNAMIC
    self.body.allowSleep = false

    self.colshape = self.node:CreateComponent("CollisionCircle2D")
    self.colshape.radius = 0.22 -- Set shape size
    self.colshape.friction = 0.5 -- Set friction
    self.colshape.restitution = 0.1 -- Slight bounce
    self.colshape:SetCategoryBits(COLMASK_PLAYER)

    self.spriteNode = self.node:CreateChild("playerSpriteNode")

    self.spriteNode:SetPosition2D(0, 0.4)

    self.animatedSprite = self.spriteNode:CreateComponent("AnimatedSprite2D")
    self.animatedSprite.animationSet = cache:GetResource("AnimationSet2D", "Urho2D/rock/player.scml")
    self.animatedSprite.animation = "idle"
    self.animatedSprite:SetLayer(SPRITELAYER_PLAYER)

    self.node:SetScale(4.5)
end

function Player:UpdateControls(moveDir, wantsToAttack)
    self.moveDir = moveDir
    self.wantsToAttack = wantsToAttack
end


function Player:Update(timeStep)

    if CurGameState ~= GAMESTATE_PLAYING then
        return
    end

    self.actionTimeElapsed = self.actionTimeElapsed + timeStep
    self.timeSinceLastAttack = self.timeSinceLastAttack + timeStep

    local node = self.node

    -- Set direction
    local speedX = MOVE_SPEED

    if self.moveDir ~= Vector2.ZERO then
        self.animatedSprite.flipX = self.moveDir.x < 0.0
        self.moveDir = Vector2(self.moveDir.x * speedX, self.moveDir.y * speedX * VERTICAL_MOVESPEED_FACTOR)
    end


    -- if not attacking, we can move
    if self.wantsToAttack and self:CanAttack() then
        self.actionTimeElapsed = 0.0
        self.timeSinceLastAttack = 0.0
        self.curPlayerState = PLAYERSTATE_ATTACKING
    end

    if self.curPlayerState ~= PLAYERSTATE_ATTACKING then
        if not self.moveDir:Equals(Vector2.ZERO) and self.canMove then
            -- node:Translate2D(self.moveDir * timeStep)
            self.body:ApplyForceToCenter(self.moveDir, true)
            self.actionTimeElapsed = 0.0
            self.curPlayerState = PLAYERSTATE_MOVING
        else
            self.curPlayerState = PLAYERSTATE_IDLE
            if self.actionTimeElapsed >= TIME_BEFORE_ROCKING then
                self.curPlayerState = PLAYERSTATE_ROCKING
            end
        end
    end


    if self.curPlayerState == PLAYERSTATE_ATTACKING then
        if self.actionTimeElapsed >= ATTACK_DURATION then
            self.curPlayerState = PLAYERSTATE_IDLE
            self.attackIsComplete = false
        elseif self.actionTimeElapsed >= ATTACK_TIME_BEFORE_HIT and not self.attackIsComplete then
            self.attackIsComplete = true
            -- apply actual attack calculations/effects!
            log:Write(LOG_DEBUG, "attack goes here!")
            --Scene_:GetComponent("PhysicsWorld2D"):Raycast()
        end
    end

    -- animation...
    if self.curPlayerState == PLAYERSTATE_ROCKING then
        self.animatedSprite:SetAnimation("rock")
    elseif self.curPlayerState == PLAYERSTATE_ATTACKING then
        self.animatedSprite:SetAnimation("attack")
    elseif self.curPlayerState == PLAYERSTATE_MOVING then
        self.animatedSprite:SetAnimation("idle")
    else
        self.animatedSprite:SetAnimation("idle")
    end


    -- reset controls
    self.moveDir = Vector2.ZERO
    self.wantsToAttack = false
end

function Player:CanAttack()
    return self.timeSinceLastAttack >= ATTACK_DURATION
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
