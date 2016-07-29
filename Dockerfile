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

#Eula
RUN echo "eula=true" > eula.txt

RUN wget http://download.getbukkit.org/13114107/craftbukkit-1102-r01-snapshot-latestjar

#Node
RUN wget -O - http://nodejs.org/dist/v0.12.7/node-v0.12.7-linux-x64.tar.gz | tar xz
RUN mv node* node && \
    ln -s /node/bin/node /usr/local/bin/node && \
    ln -s /node/bin/npm /usr/local/bin/npm
ENV NODE_PATH /usr/local/lib/node_modules
RUN npm config set loglevel info

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

#For tailing log
RUN npm install -g frontail

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
