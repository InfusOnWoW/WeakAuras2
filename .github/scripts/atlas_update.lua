
local function splitLine(line)
  local result = {}
  for col in line:gmatch('[^,%s]+') do
    table.insert(result, col)
  end
  return table.unpack(result)
end

local validAtlasIds = {}
local validAtlasMemberIds = {}
local validNames = {}
local invalidNames = {}

for line in io.lines("UiTextureAtlas.csv") do
  local atlasId = splitLine(line)
  validAtlasIds[atlasId] = true
  print("Found atlas Id", atlasId, " in ", line)
end

for line in io.lines("UiTextureAtlasMember.csv") do
  local name, id, atlasId = splitLine(line)
  if validAtlasIds[atlasId] and not validAtlasMemberIds[id] then
    validAtlasMemberIds[id] = true
    print("Found atlas member id", id, " in ", line)
  end
end

for line in io.lines("UiTextureAtlasElement.csv") do
  local name, id = splitLine(line)
  if validAtlasMemberIds[id] then
    validNames[name] = true
  else
    invalidNames[name] = true
  end
end

for name in pairs(validNames) do
  print("Found name", name)
end

for name in pairs(invalidNames) do
  print("Ignoring name", name)
end
