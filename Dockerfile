FROM ubuntu:18.04 as base
  
ENV DEBIAN_FRONTEND=noninteractive TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/skel/.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US.UTF-8 && dpkg-reconfigure locales
ENV LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD bash -c 'export > /etc/envvars && /usr/bin/runsvdir /etc/service'

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute2 python ssh rsync gettext-base

# Java
RUN apt-get --yes install default-jdk-headless

#Build
FROM base as build
RUN wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
RUN java -jar BuildTools.jar --rev 1.14.4

FROM base as final
COPY --from=build /spigot*.jar /spigot.jar

#Minecraft Server
#RUN wget -O minecraft_server.jar https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar
#RUN wget -O craftbukkit.jar https://cdn.getbukkit.org/craftbukkit/craftbukkit-1.14.3-SNAPSHOT.jar

#Node
RUN wget -O - https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-x64.tar.gz | tar xz
RUN mv node* node && \
    ln -s /node/bin/node /usr/local/bin/node && \
    ln -s /node/bin/npm /usr/local/bin/npm
ENV NODE_PATH /usr/local/lib/node_modules

# Plugins

RUN mkdir -p plugins
WORKDIR /plugins

RUN wget --trust-server-names https://dev.bukkit.org/projects/mcore/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/factions/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/nicknamesx/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/essentialscmd/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/worldedit/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/worldguard/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/vault/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/bpermissions/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/clearlagg/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/dynmap/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/multiverse-core/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/multiverse-portals/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/massivehat/files/latest
RUN wget --trust-server-names https://dev.bukkit.org/projects/echopet/files/latest

#For tailing log
RUN npm install -g frontail

#Eula
RUN echo "eula=true" > /eula.txt

RUN mkdir /data

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
