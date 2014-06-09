local dnaIngredients
local dnaCategory
if data.raw.fluid["dna"] then
  dnaIngredients = {{"iron-plate", 50}, {"basic-beacon", 5}, {type="fluid", name="dna", amount=200}}
  dnaCategory = "crafting-with-fluid"
else
  dnaIngredients = {{"iron-plate", 50}, {"basic-beacon", 5}}
  dnaCategory = "advanced-crafting"
end
data:extend(
{
  {
    type = "recipe",
    name = "MBeacon",
    category = dnaCategory,
    enabled = "false",
    ingredients = dnaIngredients,
    result = "MBeacon"
  }
})
