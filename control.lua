require "util"
require "defines"

game.oninit(function()
glob.beacons = {}
glob.minds = {}
glob.hiveminds = {} --bases
glob.minds.difficulty = false -- change to always use easy calculation
glob.beacons.release = false -- boolean used for easily testing mod during development, false gives free items oninit and possibly debug statements

if glob.minds.difficulty or (game.difficulty == defines.difficulty.easy) then
  glob.minds.difficulty = 3 -- easy difficulty
elseif (game.difficulty == defines.difficulty.normal) then
  glob.minds.difficulty = 5
else glob.minds.difficulty = 10
end

if not glob.beacons.release and game.player.character then
  game.player.character.insert{name="MBeacon", count=10}
end
end)

game.onevent(defines.events.onentitydied, function(event)
  if event.entity.name == "MBeacon" then
    beaconremove()
  end
  if event.entity.type == "unit-spawner" and event.entity.force.equals(game.forces.enemy) then
    convertBase(event.entity, true)
  end
end)

game.onevent(defines.events.onplayermineditem, function(event)
  if event.itemstack.name=="MBeacon" then
    beaconremove()
  end
end)

game.onevent(defines.events.onbuiltentity, function(event) -- Beacon has been built
  if event.createdentity.name == "MBeacon" then
    table.insert(glob.beacons, event.createdentity)
  end
end)

game.onevent(defines.events.ontick, function(event) -- check for biters within MindcontrolBeacon's range
  if (game.tick % (60 * 6) == 0) and glob.beacons[1] then
    if not glob.beacons.release then 
      game.player.print("checking")
      if game.player.character then game.player.character.health=100 end
    end
    --beaconremove() --this should be unneeded with the onentitydied and onentitymined events.
    removemindcontrol() --free out of range biters
    controlenemies() --control newly in range biters
  end
end)

function beaconremove(index)
  if index then
    if glob.beacons[index] and not glob.beacons[index].valid then
      table.remove(glob.beacons, index)
      return -- if an index was found and it's entity was not valid return after removing it
    end
  end
  -- if no index was provided, or an inappropriate index was provided then loop through the table
  -- not sure if there is a better way...perhaps I could make beacons a multidimensional table
  -- and store it's index as well, then instead of searching through the table I can simply use
  -- table.remove(glob.beacons,beacon.index)...
  for k,beacon in ipairs(glob.beacons) do
    if not beacon.valid then
      table.remove(glob.beacons,k)
      writeDebug("removed")
    end
  end--not sure if there is a better way...perhaps I could make beacons a multidimensional table and store it's index as well, then instead of searching through the table I can simply use table.remove(glob.beacons,beacon.index)...
end

function controlenemies()
  for k,beacon in ipairs(glob.beacons) do
    if beacon.valid then
      if beacon.energy > 0 then
        local bases = game.findentitiesfiltered{type="unit-spawner", area=getboundingbox(beacon.position, 30)} --search area of thirty around each beacon for spawners
        if #bases > 0 then
          for i, base in ipairs(bases) do
            if base.force.equals(game.forces.enemy) and math.random(glob.minds.difficulty*2)==1 then --easy = 16.5% chance, normal = 10%, hard = 5%
              convertBase(base, false)
            end
          end
        else -- no bases in range
          for i, enemy in ipairs(game.findenemyunits(beacon.position, 10)) do --search area of ten around each beacon
            if enemy.force.equals(game.forces.enemy) then --do only if not already controlled
              if math.random(glob.minds.difficulty)==1 then --easy = 33% chance, normal = 20%, hard = 10%
                enemy.force=game.player.force
                enemy.setcommand{type=defines.command.wander,distraction=defines.distraction.byenemy}
                table.insert(glob.minds, enemy)
                writeDebug("converted")
              end
            end
          end
        end
      else
        writeDebug("no power")
      end
    else
      beaconremove()
    end
  end
end

function removemindcontrol()
  if glob.beacons[1] then -- if there are valid beacons
    for k,mind in ipairs (glob.minds) do --remove mindcontrol from biters not in area of influence
      if not mind.valid then --first make sure the enemy is still valid, if not remove them
        table.remove(glob.minds, k)
      else -- is valid
        local controlled = false --assume out of range
        if game.findentitiesfiltered{name="MBeacon", area=getboundingbox(mind.position, 10)}[1] then --a MBeacon is in range
          controlled = true
          break
        end
        if not controlled then mind.force=game.forces.enemy end
      end
    end
  end
end

function convertBase(base, died)
  local enemies=getboundingbox(base.position, 10/game.difficulty)
  local units={}
  local hives={}
  local worms={}
  local count=0
  enemies = game.findentities(enemies)
  for i, enemy in ipairs(enemies) do
    if enemy.type=="turret" and enemy.force.equals(game.forces.enemy) then
      table.insert(worms, enemy)
    elseif enemy.type=="unit-spawner" then
      table.insert(hives, enemy)
    elseif enemy.type=="unit" then
      table.insert(units, enemy)
    end
  end
  count=#units+#hives+#worms
  if count~=0 then -- prevent empty random interval
    writeDebug(count)
    writeDebug(math.random(game.difficulty+math.pow(count, 1/4)))
  end
  if count~=0 and math.random(game.difficulty+math.sqrt(count))==1 then
    if died then table.insert(glob.hiveminds, game.createentity{name=base.name, position=base.position, force=game.player.force}) end
    for _, worm in pairs(worms) do worm.force=game.player.force writeDebug("converted base") end
    for _, hive in pairs(hives) do hive.force=game.player.force table.insert(glob.hiveminds, hive) end
    for _, unit in pairs(units) do
      unit.force=game.player.force
      unit.setcommand{type=defines.command.wander, distraction=defines.distraction.byenemy}
      -- remove mind controlled biters in range from the minds table
      --so they aren't converted back into enemies when wandering away from the beacon
      for i, controlled in ipairs(glob.minds) do
        writeDebug{unit, controlled}
        if unit.equals(controlled) then
          table.remove(glob.minds, i)
          break
        end
      end
    end
  end
end

function getboundingbox(position, radius)
return {{position.x-radius, position.y-radius}, {position.x+radius,position.y+radius}}
end

function writeDebug(message)
  if not glob.beacons.release then game.player.print(tostring(message)) end
end