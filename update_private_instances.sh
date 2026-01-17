
#!/bin/bash

# script to update a private Lizmap and QGIS instance
# first you need to update the Lizmap and QGIS server images

if [ -z "$1" ]; then
    echo "The name of private client is required"
    exit
fi

if [ ! -d "$1" ]; then
  echo "'$1' directory does not exist"
  exit
fi

USER=$1

if [ ! "$(docker ps -a -q -f name=lizmap-$USER)" ]; then
  echo "'lizmap-$USER' container does not exists"
  exit
fi

if [ ! "$(docker ps -a -q -f name=map-$USER)" ]; then
  echo "'map-$USER' container does not exists"
  exit
fi

cd $USER
mkdir /tmp/css
docker cp lizmap-$USER:/www/lizmap/www/themes/default/css/. /tmp/css/

docker compose -f private-compose.yml down

docker compose -f private-compose.yml up -d
docker exec -u 1000 -it map-$USER qgis-plugin-manager update
docker exec -u 1000 -it map-$USER qgis-plugin-manager upgrade
docker stop map-$USER
docker start map-$USER

docker cp /tmp/css/. lizmap-$USER:/www/lizmap/www/themes/default/css/
rm -rf /tmp/css
RED='\033[0;31m'
echo -e "${RED}Remember to check the file $USER/var/lizmap-config/lizmapConfig.ini.php"
cd ..
