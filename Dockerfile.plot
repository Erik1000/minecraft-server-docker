# build plotsquared
FROM gradle:jdk17-alpine AS plotsquared
RUN git clone https://github.com/IntellectualSites/PlotSquared.git
WORKDIR /home/gradle/PlotSquared
RUN gradle build --info

# build armorstandtools
FROM maven:latest As ast
RUN git clone https://github.com/Aurelien30000/ArmorStandTools.git 
WORKDIR /ArmorStandTools
RUN mvn -B package --file pom.xml

# server setup
FROM itzg/minecraft-server AS base

ARG version=LATEST

# accept the eula because I do
ENV EULA=true
ENV VERSION=${version}
# we always run on paper
ENV TYPE=PAPER
# we use a bungeecord server
ENV ONLINE_MODE=false
# used to send commands via docker exec
ENV ENABLE_RCON=true
# saves cpu time
ENV ENABLE_AUTOPAUSE=true
ENV MAX_TICK_TIME=-1
# easier configuration 
ENV COPY_CONFIG_DEST=/data
# replaces files for /config
ENV SYNC_SKIP_NEWER_IN_DESTINATION=false
# removes old plugins 
ENV REMOVE_OLD_MODS=true
ENV REMOVE_OLD_MODS_INCLUDE="*.jar"

# replace config values at runtime
ENV REPLACE_ENV_IN_PLACE=true

## plugins
# download LuckPerms
RUN wget $(curl -s https://metadata.luckperms.net/data/downloads | jq --raw-output '.downloads.bukkit') -P /plugins
# download FastAsyncWorldEdit
RUN wget "https://ci.athion.net/job/FastAsyncWorldEdit/lastSuccessfulBuild/artifact/"$(curl -s https://ci.athion.net/job/FastAsyncWorldEdit/lastSuccessfulBuild/api/json | jq --raw-output -c '.artifacts[] | select(.fileName | contains("-Bukkit")) | .relativePath') -P /plugins
# download WorldGuard
RUN wget --content-disposition --trust-server-names https://dev.bukkit.org/projects/worldguard/files/latest -P /plugins
# download EssentialsX
RUN wget "https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/"$(curl -s https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/api/json | jq --raw-output -c '.artifacts[] | select(.fileName | startswith("EssentialsX-")) | .relativePath') -P /plugins
# # download floodgate
# RUN wget --content-disposition --trust-server-names https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot -P /plugins

# copy built jars
COPY --from=plotsquared /home/gradle/PlotSquared/Bukkit/build/libs/plotsquared-bukkit-*SNAPSHOT.jar /plugins
COPY --from=ast /ArmorStandTools/target/ArmorStandTools*.jar /plugins

# copy given plugin folders
COPY configs/plugins/ /plugins/
COPY configs/server/ /config/