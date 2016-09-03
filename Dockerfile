FROM ubuntu:14.04
  
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Minecraft Server
RUN wget -O minecraft_server.jar https://s3.amazonaws.com/Minecraft.Download/versions/1.10.2/minecraft_server.1.10.2.jar
RUN wget -O craftbukkit.jar https://www.getbukkit.org/files/craftbukkit-1.10.2-R0.1-SNAPSHOT-latest.jar

#Node
RUN wget -O - http://nodejs.org/dist/v6.5.0/node-v6.5.0-linux-x64.tar.gz | tar xz
RUN mv node* node && \
    ln -s /node/bin/node /usr/local/bin/node && \
    ln -s /node/bin/npm /usr/local/bin/npm
ENV NODE_PATH /usr/local/lib/node_modules

#Plugins
RUN mkdir -p plugins
RUN cd plugins && \
    wget http://dev.bukkit.org/media/files/889/301/MassiveCore.jar
RUN cd plugins && \
    wget http://dev.bukkit.org/media/files/889/302/Factions.jar
RUN cd plugins && \
    wget http://dev.bukkit.org/media/files/809/44/NickNames.jar
RUN cd plugins && \
    wget http://dev.bukkit.org/media/files/893/378/EssentialsCmd_v1.0.9.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/media/files/922/48/worldedit-bukkit-6.1.3.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/media/files/920/773/worldguard-6.1.2.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/media/files/894/359/Vault.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/media/files/941/243/bPermissions-2.12.jar
RUN cd plugins && \
    wget https://dev.bukkit.org/media/files/910/762/LaggRemover-0.2.2.jar


#For tailing log
RUN npm install -g frontail

#Eula
RUN echo "eula=true" > /eula.txt

RUN mkdir /data

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
