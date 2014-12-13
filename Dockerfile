FROM ubuntu:14.04
MAINTAINER Dave P

# Create rduser (password is rduser)
RUN useradd --groups sudo,audio rduser
RUN echo "rduser:rduser" | chpasswd 

# Install prereqs for edcast compile
RUN apt-get update
RUN apt-get -y install debconf-utils libjack0 libjack-dev libflac-dev libogg-dev libvorbis-dev libmad0-dev libmp3lame-dev g++ make wget

# Download libfaac manually (copyright?)
RUN wget http://launchpadlibrarian.net/157472510/libfaac-dev_1.28-6_amd64.deb
RUN wget http://launchpadlibrarian.net/157472509/libfaac0_1.28-6_amd64.deb

# Install libfaac
RUN dpkg -i libfaac0_1.28-6_amd64.deb
RUN dpkg -i libfaac-dev_1.28-6_amd64.deb

# Compile & install edcast
COPY edcast-jack-3.1.7.tar.gz /tmp/
RUN tar zxvf /tmp/edcast-jack-3.1.7.tar.gz
RUN cd edcast-jack-3.1.7/ ; ./configure
RUN cd edcast-jack-3.1.7/ ; make
RUN cd edcast-jack-3.1.7/ ; make install

# Configure icecast
RUN echo "icecast2 icecast2/icecast-setup boolean false" | debconf-set-selections && \
    apt-get -y install icecast2

COPY icecast /etc/default/icecast
COPY icecast.xml /etc/default/icecast.xml

# Install tryphon repos
RUN wget -q -O - http://debian.tryphon.eu/release.asc | apt-key add -
COPY tryphon.list /etc/apt/sources.list.d/tryphon.list

# Install rivendell and other goodies
RUN apt-get update
RUN echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections && \
    echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections && \
    echo "rivendell-server rivendell-server/debconfenable boolean false" | debconf-set-selections && \
    apt-get -y install rivendell rivendell-server rivendell-doc mysql-server jack-rack jamin jackd

COPY rd.conf /etc/rd.conf

# Alsa (is this necessary?)
RUN apt-get -y install alsa-base alsa-utils

# VNC Server / X desktop
RUN apt-get -y install icewm
RUN apt-get -y install tightvncserver



















#docker build -t rivendell2 .


# TODO: cleanup extra packages like g++, make, etc

