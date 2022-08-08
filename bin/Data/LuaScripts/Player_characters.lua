---@class PlayerCharacterData
---@field attackDuration number
---@field attackTimeBeforeHit number
---@field attackReach number
---@field attackPushForce number
---@field attackDamage number
---@field attackStunTime number
---@field timeBeforeRocking number
---@field moveSpeed number
---@field animSpritePath string
---@field portraitSpritePath string
---@field spriteScaling number
---@field name string
---@field voicePitch number
---@field themeSongPath string


---@type PlayerCharacterData[]
local charOptions = {
    {
        name = "Johnny",
        animSpritePath = "Urho2D/rock/johnny.scml",
        portraitSpritePath = "Urho2D/rock/portrait_johnny.png",
        spriteScaling = 1.0,
        moveSpeed = 40.0,
        attackDuration = 0.3,
        attackTimeBeforeHit = 0.15,
        attackReach = 4.5,
        attackDamage = 1.5,
        attackStunTime = 0.35,
        attackPushForce = 80,
        timeBeforeRocking = 1.0,
        voicePitch = 1.0,
        themeSongPath = "Music/rock/GreenDaze.ogg"
    },
    {
        name = "Countrygirl",
        animSpritePath = "Urho2D/rock/countrygirl.scml",
        portraitSpritePath = "Urho2D/rock/portrait_countrygirl.png",
        spriteScaling = 0.4,
        moveSpeed = 60.0,
        attackDuration = 0.3,
        attackTimeBeforeHit = 0.15,
        attackReach = 3.5,
        attackDamage = 1.3,
        attackStunTime = 0.55,
        attackPushForce = 60,
        timeBeforeRocking = 1.0,
        voicePitch = 1.6,
        themeSongPath = "Music/rock/TexasTechno.ogg"
    },
    {
        name = "Goth",
        animSpritePath = "Urho2D/rock/goth.scml",
        portraitSpritePath = "Urho2D/rock/portrait_goth.png",
        spriteScaling = 0.4,
        moveSpeed = 50.0,
        attackDuration = 0.4,
        attackTimeBeforeHit = 0.25,
        attackReach = 4.5,
        attackDamage = 1.9,
        attackStunTime = 0.55,
        attackPushForce = 90,
        timeBeforeRocking = 1.0,
        voicePitch = 1.8,
        themeSongPath = "Music/rock/PopMetal.ogg"
    },
    {
        name = "Jimmy",
        animSpritePath = "Urho2D/rock/jimmy.scml",
        portraitSpritePath = "Urho2D/rock/portrait_jimmy.png",
        spriteScaling = 0.3,
        moveSpeed = 40.0,
        attackDuration = 0.4,
        attackTimeBeforeHit = 0.25,
        attackReach = 4.5,
        attackDamage = 1.9,
        attackStunTime = 0.55,
        attackPushForce = 90,
        timeBeforeRocking = 1.0,
        voicePitch = 0.9,
        themeSongPath = "Music/rock/Whatdafunk.ogg"
    }
}

return charOptions