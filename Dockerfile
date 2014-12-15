FROM ubuntu:14.04
MAINTAINER Dave P


# Create rduser (password is rduser)
RUN useradd --create-home --groups sudo,audio rduser ; \
    echo "rduser:rduser" | chpasswd 


# Install edcast_jack prereqs
# Download & install libfaac manually (copyright?)
RUN apt-get update ; \
    apt-get -y install debconf-utils libjack0 libjack-dev libflac-dev libogg-dev libvorbis-dev libmad0-dev libmp3lame-dev g++ make wget ; \
    wget http://launchpadlibrarian.net/157472510/libfaac-dev_1.28-6_amd64.deb ; \
    wget http://launchpadlibrarian.net/157472509/libfaac0_1.28-6_amd64.deb ; \
    dpkg -i libfaac0_1.28-6_amd64.deb ; \
    dpkg -i libfaac-dev_1.28-6_amd64.deb

# Compile & install edcast
COPY edcast-jack-3.1.7.tar.gz /tmp/
RUN tar zxvf /tmp/edcast-jack-3.1.7.tar.gz ; \
    cd edcast-jack-3.1.7/ ; ./configure ; \
    cd edcast-jack-3.1.7/ ; make ; \
    cd edcast-jack-3.1.7/ ; make install
COPY edcast.cfg /home/rduser/edcast.cfg


# Configure icecast
RUN echo "icecast2 icecast2/icecast-setup boolean false" | debconf-set-selections ; \
    apt-get -y install icecast2

COPY icecast /etc/default/icecast
COPY icecast.xml /etc/icecast2/icecast.xml

# Install mysql server
RUN echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections ; \
    echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections ; \
    apt-get -y install mysql-server mysql-client


# Install tryphon repos
RUN wget -q -O - http://debian.tryphon.eu/release.asc | apt-key add -
COPY tryphon.list /etc/apt/sources.list.d/tryphon.list


# Install Rivendell and other audio goodies
RUN apt-get update ; \
    echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections ; \
    echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections ; \
    echo "rivendell-server rivendell-server/debconfenable boolean false" | debconf-set-selections ; \
    apt-get -y install rivendell rivendell-server rivendell-doc mysql-server jack-rack jamin jackd qjackctl
COPY rdmysql.conf /etc/mysql/conf.d/rdmysql.cnf

COPY rd.conf /etc/rd.conf
COPY init.sh /home/rduser/init.sh
RUN chmod +x /home/rduser/init.sh


# Install Alsa (is this necessary?)
RUN apt-get -y install alsa-base alsa-utils


# Install VNC Server / X desktop software
RUN apt-get -y install icewm xterm ; \
    apt-get -y install tightvncserver ; \
    su -c "mkdir /home/rduser/.vnc" rduser ; \
    su -c "echo 'rduser' | vncpasswd -f > /home/rduser/.vnc/passwd" rduser ; \
    chmod 700 /home/rduser/.vnc ; \
    chmod 600 /home/rduser/.vnc/passwd


# Install SSH server
RUN mkdir /var/run/sshd ; \
    apt-get -y install openssh-server


# Install supervisor & start script
RUN apt-get -y install supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start /start
RUN chmod +x /start


# Expose ssh, vnc, icecast
EXPOSE 22
EXPOSE 5900
EXPOSE 8000


# Set boot command
CMD /start
