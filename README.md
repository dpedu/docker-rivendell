Rivendell & Docker
==================

**How to use:**

* Install docker
* Clone this repo; cd into it
* Create an image in Docker: `docker build -t rivendell .` (this step takes about 20 minutes)
* Start a new container using the image: `docker run -d -p 5900 -p 8000 -p 22 rivendell`

**Access:**

After using the exact commands above, `docker ps` will show you what ports on the docker host have been mapped to the container. Of course, you can use `-p hostport:containerport` like `-p 666:22` to specify what ports to use.

**SSH** *- exposed on port 22:* Username & password is **rduser**.

**VNC** *- exposed on port 5900:* Password is **rduser**

**Icecast** *- exposed on port 8000:* Admin panel is username **admin** password **rduser**. (No authorization needed to simply view streams.)

What it does by default
=======================

Creates and installs a Rivendell server, with the barebones software components to play audio and see how a full Rivendell stack would behave.

* **SSH:** a ssh server runs to allow easy remote access to inspect the docker container's internals

* **Icecast:** a stream (named simply "stream") is made available. It's silent until RDAirplay pushes audio to it.

* **VNC:** a VNC session providing minimal desktop functionality is started

* **JACKD:** runs invisibly behind the scenes

* **Rivendell:** a RDAirplay window is brought up by default

To "hear" the system working, all a user needs to do is press Add in RDAirplay, select an audio file, and press Start.

Known Issues
============

* Clicking 'Add' on the rdairplay window created by default causes the window to close. After bringing up another window (through xterm), the button functions normally. This *should* be fixed
* Apache occasionally needs a manual restart after the container is started. This *should* be fixed

Thanks to:
==========

* Rivendell - http://www.rivendellaudio.org/
* Jackd - http://jackaudio.org/
* Edcast for jackd - (and older version of) https://code.google.com/p/edcast-reborn/
* Icecast - http://icecast.org/
* Jamin - http://jamin.sourceforge.net/
* Tryphon Debian Repository - http://debian.tryphon.eu/
* MySQL - http://www.mysql.com/
* Ubuntu - http://www.ubuntu.com/
* IceWM - http://www.icewm.org/

Upcoming Roadmap
================

* Customize (or use a different) window manager. (XFCE?)
* Autoplay RDAirplay on boot
* Set up an audio file [dropbox](http://rivendell.tryphon.org/wiki/Dropboxes)
* Include basic log generation rules by default
* On first boot, if input data is available, import dropbox'd music and generate a basic log using it
* On first boot, if input data is available, automatically load the log into RDAirplay 
