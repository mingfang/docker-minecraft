FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/bash.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/bash.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt install oracle-java8-unlimited-jce-policy && \
    rm -r /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Minecraft Server
RUN wget -O minecraft_server.jar https://s3.amazonaws.com/Minecraft.Download/versions/1.11.2/minecraft_server.1.11.2.jar
RUN wget -O craftbukkit.jar https://cdn.getbukkit.org/craftbukkit/craftbukkit-1.11.2.jar

#Node
RUN wget -O - https://nodejs.org/dist/v7.9.0/node-v7.9.0-linux-x64.tar.gz | tar xz
RUN mv node* node && \
    ln -s /node/bin/node /usr/local/bin/node && \
    ln -s /node/bin/npm /usr/local/bin/npm
ENV NODE_PATH /usr/local/lib/node_modules

#Plugins
RUN mkdir -p plugins
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/mcore/files/2377287/MassiveCore.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/factions/files/2377285/Factions.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/nicknamesx/files/2402665/NickNamesX.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/essentialscmd/files/954929/EssentialsCmd_v1.1.3.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/worldedit/files/956525/worldedit-bukkit-6.1.5.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/worldguard/files/956770/worldguard-6.2.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/vault/files/894359/Vault.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/bpermissions/files/941243/bPermissions-2.12.1.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/laggremoverplus/files/939930/LaggRemoverPlus-1.1.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/dynmap/files/2380584/dynmap-2.4.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/multiverse-core/files/912081/Multiverse-Core-2.5-b717.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/multiverse-portals/files/898528/Multiverse-Portals-2.6-b725.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/massivehat/files/2377288/MassiveHat-2.10.0.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/projects/echopet/files/879595/EchoPet_v2.8.0.jar

#For tailing log
RUN npm install -g frontail

#Eula
RUN echo "eula=true" > /eula.txt

RUN mkdir /data

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
