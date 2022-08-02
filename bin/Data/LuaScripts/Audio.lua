local GameAudio = {}

---@type SoundSource
local musicSource = nil

local mainAudioFrequency = 22050

--- creates elements for playing music and creates the main sound listener at the game camera
function GameAudio.SetupSound()

  -- Create music sound sources
  musicSource = Scene_:CreateComponent("SoundSource")
  -- Set the sound type to music so that master volume control works correctly
  musicSource.soundType = SOUND_MUSIC

  -- add listener to camera
  local listener = GameCameraNode:CreateComponent("SoundListener")
  audio:SetListener(listener)
end


function GameAudio.StartMusic()
  ---@type Sound
  local musicFile = cache:GetResource("Sound","Music/duality/gameplayv1.ogg")

  if musicFile then
    musicFile.looped = true
  end

  if not musicSource:IsPlaying() then
    musicSource:Play(musicFile)
  end

  musicSource:SetGain(0.63)
end

function GameAudio.StopMusic()
  -- MusicSource:Stop()
  musicSource:Stop()
end

---@param soundFilePath string
---@param gain number?
---@param freqVariation number?
---@param is3dSound boolean?
---@param emittingNode Node | Scene?
function GameAudio.PlayOneShotSoundWithFreqVariation(soundFilePath, gain, freqVariation, is3dSound, emittingNode)
  -- Get the sound resource
  local sound = cache:GetResource("Sound", soundFilePath)

  if sound ~= nil then
    -- Create a SoundSource component for playing the sound. The SoundSource component plays
    -- non-positional audio, so its 3D position in the scene does not matter. For positional sounds the
    -- SoundSource3D component would be used instead

    ---@type SoundSource | SoundSource3D
    local soundSource = nil

    if emittingNode == nil then
      emittingNode = Scene_
    end

    if is3dSound then
      soundSource = emittingNode:CreateComponent("SoundSource3D") --[[@as SoundSource3D]]
    else
      soundSource = emittingNode:CreateComponent("SoundSource") --[[@as SoundSource]]
    end

    soundSource:SetSoundType(SOUND_EFFECT)
    soundSource:SetAutoRemoveMode(REMOVE_COMPONENT)

    if gain == nil then
      gain = 1.0
    end

    if freqVariation == nil then
      freqVariation = 0.0
    end

    soundSource:Play(sound, Random(mainAudioFrequency - freqVariation, mainAudioFrequency + freqVariation), gain)

  end
end

---@param soundFilePath string
---@param gain number?
---@param frequency number?
---@param is3dSound boolean?
---@param emittingNode Node | Scene?
function GameAudio.PlayOneShotSoundWithFrequency(soundFilePath, gain, frequency, is3dSound, emittingNode)
  -- Get the sound resource
  local sound = cache:GetResource("Sound", soundFilePath)

  if sound ~= nil then
    -- Create a SoundSource component for playing the sound. The SoundSource component plays
    -- non-positional audio, so its 3D position in the scene does not matter. For positional sounds the
    -- SoundSource3D component would be used instead

    ---@type SoundSource | SoundSource3D
    local soundSource = nil

    if emittingNode == nil then
      emittingNode = Scene_
    end

    if is3dSound then
      soundSource = emittingNode:CreateComponent("SoundSource3D") --[[@as SoundSource3D]]
    else
      soundSource = emittingNode:CreateComponent("SoundSource") --[[@as SoundSource]]
    end

    soundSource:SetSoundType(SOUND_EFFECT)
    soundSource:SetAutoRemoveMode(REMOVE_COMPONENT)

    if gain == nil then
      gain = 1.0
    end

    if frequency == nil then
      frequency = mainAudioFrequency
    end

    soundSource:Play(sound, frequency, gain)

  end
end

function GameAudio.HandleSoundVolume(eventType, eventData)
  local newVolume = eventData["Value"]:GetFloat()
  audio:SetMasterGain(SOUND_EFFECT, newVolume)
end

function GameAudio.HandleMusicVolume(eventType, eventData)
  local newVolume = eventData["Value"]:GetFloat()
  audio:SetMasterGain(SOUND_MUSIC, newVolume)
end


return GameAudio