#!/bin/bash
# ---------------Parameters------------------
# $1 : force delete python installation folder (optional)

# DOCKER_BUILDKIT=1
source ./.env

reCreatePassword() {
  local mongoFile="$MONGO_PW_ROOT_PATH"
  
  openssl rand -base64 14 | awk '{print tolower($0)}' > "$mongoFile"

  echo "Recreating password..."
}


init(){
  # ---------------Parameters------------------
  # $1 : force delete python installation folder 

  local ReCreateInstallation="$1"

  if [[ "$ReCreateInstallation" == "true" ]]
  then
    rm -rf ./Python/Installation
    reCreatePassword
  fi

  mkdir -p ./VsCodeConfigFolders/Python
  
  # docker-compose -f "docker-compose.yml" down
  docker-compose -f "docker-compose.yml" up -d --build
  mkdir Monitor
  docker-compose -f "Monitor/docker-compose-influx.yml" up -d --build 
}

if [[ "true" ]]; then
  init $1
fi
