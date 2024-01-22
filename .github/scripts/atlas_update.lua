local ftcsv = require('ftcsv')

-- TODO delete old atlas lua files

local validAtlasIds = {}
local validAtlasElementIds = {}
local validNames = {}

for lineNr, atlas in ftcsv.parseLine("UiTextureAtlas.csv", ",") do
  validAtlasIds[atlas.ID] = true
end

for lineNr, member in ftcsv.parseLine("UiTextureAtlasMember.csv", ",") do
  local uiTextureAtlasID = member.UiTextureAtlasID
  local uiTextureAtlasElementId = member.UiTextureAtlasElementID

  if validAtlasIds[uiTextureAtlasID] and not validAtlasElementIds[uiTextureAtlasElementId] then
    validAtlasElementIds[uiTextureAtlasElementId] = true
  end
end

for lineNr, element in ftcsv.parseLine("UiTextureAtlasElement.csv", ",") do
  local name = element.Name
  local id = element.ID
  if validAtlasElementIds[id] and name:lower():sub(1, 5) ~= "cguy_" then
    validNames[name] = true
  end
end

for name in pairs(validNames) do
  print("Found +", name)
end
