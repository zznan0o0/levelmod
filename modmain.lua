local GetPlayer = GLOBAL.GetPlayer
local print_table = GLOBAL.print_table
local GetWorld = GLOBAL.GetWorld
local TUNING = GLOBAL.TUNING

local function setCharacterAttribute(inst)
  -- GetPlayer().components.health:SetMaxHealth(inst.init_health + inst.LevelupLevel) 
  -- GetPlayer().components.sanity:SetMax(inst.init_sanity + inst.LevelupLevel)
  -- GetPlayer().components.hunger:SetMax(inst.init_hunger + inst.LevelupLevel)
  inst.components.health.maxhealth = (inst.init_health + inst.LevelupLevel) 
  inst.components.sanity.max = (inst.init_sanity + inst.LevelupLevel)
  inst.components.hunger.max = (inst.init_hunger + inst.LevelupLevel)
  inst.components.locomotor.walkspeed = (inst.init_walkspeed + inst.LevelupLevel / 10)
  inst.components.locomotor.runspeed = (inst.init_runspeed + inst.LevelupLevel / 10)
  -- inst.components.combat.defaultdamage = (inst.init_defaultdamage + inst.LevelupLevel / 10)
end

local function say(inst) 
  local talk_str = string.format("level: %d, exp: %d/%d", inst.LevelupLevel, inst.LevelupExp, math.ceil(inst.LevelupNextExp))
  inst.components.talker:Say(talk_str , 4, false)
end



local function onkill(inst, data)
  -- print(inst.components.combat.defaultdamage)
  -- print(inst.components.locomotor.runspeed)
  -- print(TUNING.WILSON_WALK_SPEED)
  -- print(TUNING.WILSON_RUN_SPEED)
  -- print(inst.prefab)

  -- and not data.inst:HasTag("veggie") 
  if data.cause == inst.prefab and not data.inst:HasTag("structure") then
    local exp = data.inst.components.health.maxhealth / 100 
    inst.LevelupExp = exp + inst.LevelupExp

    if inst.LevelupExp >= inst.LevelupNextExp then
      inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")

      inst.LevelupExp = inst.LevelupExp - inst.LevelupNextExp
      inst.LevelupLevel = inst.LevelupLevel + 1
      inst.LevelupNextExp = inst.LevelupNextExp + math.ceil(10 / inst.LevelupLevel)
      setCharacterAttribute(inst)
      say(inst)
    end
  end

end
local function onload(inst, data) 
  -- TUNING.WILSON_WALK_SPEED = 80
  -- TUNING.WILSON_RUN_SPEED = 120
  -- inst.components.locomotor.walkspeed = 50
  -- inst.components.locomotor.runspeed = 50
  -- inst.init_health = GetPlayer().components.health.maxhealth
  -- inst.init_sanity = GetPlayer().components.sanity.max
  -- inst.init_hunger = GetPlayer().components.hunger.max
  inst.init_health = inst.components.health.maxhealth
  inst.init_sanity = inst.components.sanity.max
  inst.init_hunger = inst.components.hunger.max
  inst.init_walkspeed = inst.components.locomotor.walkspeed
  inst.init_runspeed = inst.components.locomotor.runspeed
  inst.init_defaultdamage = inst.components.combat.defaultdamage

  inst.LevelupExp = 0
  inst.LevelupLevel = 0
  inst.LevelupNextExp = 0

  if data then
    inst.LevelupExp = data.LevelupExp or 0
    inst.LevelupLevel = data.LevelupLevel or 0
    inst.LevelupNextExp = data.LevelupNextExp or 10
  end

  setCharacterAttribute(inst)
  -- inst:ListenForEvent("death", function(inst, data) onkill(inst, data) end)
  -- inst:ListenForEvent("attacked", function(inst, data) onkill(inst, data) end)
  inst:ListenForEvent("entity_death", function(wrld, data) onkill(inst, data) end, GetWorld())
  -- inst:ListenForEvent("entity_death", function(wrld, data) onkill(inst, data) end)

  GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_L, function() say(inst) end)
end

local function onsave(inst, data)
  data.LevelupExp = inst.LevelupExp
  data.LevelupLevel = inst.LevelupLevel
  data.LevelupNextExp = inst.LevelupNextExp
end

AddPlayerPostInit(function(inst)
  inst.OnPreLoad = onload
  inst.OnSave = onsave
end)
