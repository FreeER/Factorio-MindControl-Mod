data:extend({
  {
    type = "radar",
    name = "MBeacon",
    icon = "__mindcontrol__/graphics/icons/MBeacon.png",
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 2, result = "MBeacon"},
    max_health = 150,
    corpse = "medium-remnants",
    resistances = 
    {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    energy_per_sector = 20000,
    max_distance_of_sector_revealed = 14,
    energy_per_nearby_scan = 500,
    energy_source =
    {
      type = "electric",
      input_priority = "secondary"
    },
    energy_usage_per_tick = 10,
    pictures =
    {
      filename = "__mindcontrol__/graphics/entity/MBeacon.png",
      priority = "low",
      frame_width = 176,
      frame_height = 186,
      direction_count = 32,
      line_length = 6,
      shift = {1.2, 0.5}
    }
  },
})
