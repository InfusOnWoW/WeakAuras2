local ftcsv = require('ftcsv')

-- TODO delete old atlas lua files
local function splitLine(line)
  local result = {}
  for col in line:gmatch('[^,%s]+') do
    table.insert(result, col)
  end
  return table.unpack(result)
end

local validAtlasIds = {}
local validAtlasElementIds = {}
local validNames = {}

for lineNr, atlas in ftcsv.parseLine("UiTextureAtlas.csv", ",") do
  validAtlasIds[atlas.ID] = true
end

for lineNr, member in ftcsv.parseLine("UiTextureAtlasMember.csv", ",") do
  local uiTextureAtlasID = member.UiTextureAtlasID
  local uiTextureAtlasElementId = member.UiTextureAtlasElementID

  print(uiTextureAtlasID, uiTextureAtlasElementId)

  if validAtlasIds[uiTextureAtlasID] and not validAtlasElementIds[uiTextureAtlasElementId] then
    validAtlasElementIds[uiTextureAtlasElementId] = true
  end
end

for line in io.lines("UiTextureAtlasElement.csv") do
  local name, id = splitLine(line)
  name = name:lower()
  if validAtlasElementIds[id] and name:lower():sub(1, 5) ~= "cguy_" then
    validNames[name] = true
  end
end

for name in pairs(validNames) do
  print("Found +", name)
end
