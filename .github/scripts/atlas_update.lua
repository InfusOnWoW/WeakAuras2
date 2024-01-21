
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
local invalidNames = {}

local oldNames = {}

for line in io.lines("UiTextureAtlas.csv") do
  local atlasId = splitLine(line)
  validAtlasIds[atlasId] = true
  --print("Found atlas Id", atlasId, " in ", line)
end

for line in io.lines("UiTextureAtlasMember.csv") do
  local name, id, uiTextureAtlasID, left, right, top, bottom, uiTextureAtlasElementId = splitLine(line)
  name = name:lower()
  if validAtlasIds[uiTextureAtlasID] and not validAtlasElementIds[uiTextureAtlasElementId] then
    validAtlasElementIds[uiTextureAtlasElementId] = true
    --print("Found atlas member id", id, " in ", line)
  end
  oldNames[name] = true
end

for line in io.lines("UiTextureAtlasElement.csv") do
  local name, id = splitLine(line)
  name = name:lower()
  if validAtlasElementIds[id] then
    validNames[name] = true
  else
    invalidNames[name] = true
  end
end

for name in pairs(validNames) do
  print("Found +", name)
end
