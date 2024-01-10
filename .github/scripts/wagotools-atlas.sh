#!/bin/bash

for version in wow wow_classic wow_classic_era
do
  wget -O "UiTextureAtlas.csv" "https://wago.tools/db2/UiTextureAtlas/csv?${version}"
  wget -O "UiTextureAtlasMember.csv" "https://wago.tools/db2/UiTextureAtlasMember/csv?${version}"
  wget -O "UiTextureAtlasElement.csv" "https://wago.tools/db2/UiTextureAtlasElement/csv?${version}"

  lua ./atlas_update.lua ${version}
  if [ $? -ne 0 ]; then
    echo "error while creating ${version} lua file"
  else
    echo "Success"
    # mv ModelPaths*.lua ../../WeakAurasModelPaths/
  fi

done
