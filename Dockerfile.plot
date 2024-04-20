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
FROM ghcr.io/erik1000/minecraft-server-docker:base-latest AS base

# copy built jars
COPY --from=plotsquared /home/gradle/PlotSquared/Bukkit/build/libs/plotsquared-bukkit-*SNAPSHOT.jar /plugins
COPY --from=ast /ArmorStandTools/target/ArmorStandTools*.jar /plugins
