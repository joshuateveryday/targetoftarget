_addon.name     = 'targetoftarget'
_addon.author   = 'Shozokui'
_addon.version  = '1.0'
_addon.commands = {}


require('luau')
texts = require('texts')

defaults = {}
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 200
defaults.display.pos.y = 200
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 102
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 12

settings = config.load(defaults)
settings:save()

text_box = texts.new(defaults.display, settings)

initialize = function(text, settings)
    local properties = L{}
    properties:append('  Targeting: ${targetoftarget}  ')
    text:clear()
    text:append(properties:concat('\n'))
end

text_box:register_event('reload', initialize)


local target_cache = {}

function get_valid_actors() 
  actors = windower.ffxi.get_mob_array()
  valid_actors = {}
  for index, actor in pairs(actors) do 
    if (actor.valid_target and actor.status == 1 and actor.entity_type == 8) then -- check if actor is valid target, currently fighting, and a mob
      valid_actors[index] = actor
    end
  end
  return valid_actors 
end

function update_target_info(target_of_target) 
  local info = {}
  info.targetoftarget = target_of_target 
  text_box:update(info)
  text_box:show()
end

windower.register_event('action', function(act)
  -- get list of valid actors
  valid_actors = get_valid_actors()
  -- get the entity info for action actor
  actor = windower.ffxi.get_mob_by_id(act.actor_id)
  if valid_actors[actor.index] ~= nil then -- Check if actor is a valid actor
    -- Cache the target info
    target_of_target = windower.ffxi.get_mob_by_id(act.targets[1].id)
    target_cache[actor.index] = target_of_target.name
    current_target = windower.ffxi.get_mob_by_target('t')
    if current_target ~= nil and actor.id == current_target.id then 
      update_target_info(target_of_target.name)
    end
  end
end)

windower.register_event('target change', function(index)
  if index ~= 0 then 
    target_of_target = target_cache[index]
    if target_of_target ~= nil then 
      update_target_info(target_of_target)
    end
  else 
    text_box:hide()
  end
end)