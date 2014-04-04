if data.raw.item["dna"] then dnaIngredients = {{"iron-plate", 50}, {"basic-beacon", 5}, {"dna", 200}} else dnaIngredients = {{"iron-plate", 50}, {"basic-beacon", 5}} end
data:extend(
{
  {
    type = "recipe",
    name = "MBeacon",
    enabled = "false",
    ingredients = dnaIngredients,
    result = "MBeacon"
  }
})
