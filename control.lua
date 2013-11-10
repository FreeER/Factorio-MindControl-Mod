require "util"
require "defines"

game.oninit(function()
glob.beacons = {}
glob.minds = {}
glob.minds.difficulty = false -- change to always use easy calculation
glob.beacons.release = true -- boolean used for easily testing mod during developement, false gives free items oninit and possibly debug statements

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
end)

game.onevent(defines.events. onplayermineditem, function(event)
  if event.itemstack.name=="MBeacon" then
    beaconremove()
  end
end)

game.onevent(defines.events.onbuiltentity, function(event) -- Beacon has been built
  if event.createdentity.name == "MBeacon" then
    glob.beacons[#glob.beacons+1] = event.createdentity
  end
end)

game.onevent(defines.events.ontick, function(event) -- check for biters within MindcontrolBeacon's range
  if (game.tick % (60 * 6) == 0) and glob.beacons[1] then
    if not glob.beacons.release then 
      game.player.print("checking")
      if game.player.character then game.player.character.health=100 end
    end
    beaconremove()
    removemindcontrol()
    controlenemies()
  end
end)

function beaconremove()
  for k,beacon in ipairs(glob.beacons) do
    if not beacon.valid then
      table.remove(glob.beacons,k)
      if not glob.beacons.release then game.player.print("removed") end
    end
  end--not sure if there is a better way...perhaps I could make beacons a multidimensional table and store it's index as well, then instead of searching through the table I can simply use table.remove(glob.beacons,beacon.index)...
end

function controlenemies()
  for k,beacon in ipairs(glob.beacons) do
    if beacon.energy > 0 then 
      for i, enemy in ipairs(game.findenemyunits(beacon.position, 10)) do --search area of ten around each beacon
        if enemy.force.equals(game.forces.enemy) then --do only if not already controlled
          if math.random(glob.minds.difficulty)==1 then --easy = 33% chance, normal = 20%, hard = 10%
            enemy.force=game.player.force
            enemy.setcommand{type=defines.command.wander,distraction=defines.distraction.byenemy}
            glob.minds[#glob.minds+1] = enemy
            if not glob.beacons.release then game.player.print("converted") end
          end
        end
      end
    elseif not glob.beacons.release then game.player.print("no power")
    end
  end
end

function removemindcontrol()
  if glob.beacons[1] then -- if there are valid beacons
    for k,mind in ipairs (glob.minds) do --remove mindcontrol from biters not in area of influence
      if not valid then --first make sure the enemy is still valid, if not remove them
        table.remove(glob.minds, k)
      else -- is valid
        local controlled = false
          for i,beacon in ipairs (glob.beacons) do
            if util.distance(mind.position, beacon.position) < 10 then
              controlled = true
            end
            if controlled then break end
          end
        if not controlled then mind.force=game.forces.enemy end
      end
    end
  end
end
