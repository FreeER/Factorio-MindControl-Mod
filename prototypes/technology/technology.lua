if data.raw.item["dna"] then dnaPrereqs = {"dna", "effect-transmission"} else dnaPrereqs = {"alien-technology", "effect-transmission"} end
data:extend({
  {
    type = "technology",
    name = "mind-control",
    icon = "__mindcontrol__/graphics/technology/MBeacon.png",
    effects =
    {
      {type = "unlock-recipe", recipe = "MBeacon"}
    },
    prerequisites = dnaPrereqs,
    unit =
    {
      count = 50,
      ingredients =
      {
        {"science-pack-1", 6},
        {"science-pack-2", 6}
      },
      time = 30
    },
  }
})
