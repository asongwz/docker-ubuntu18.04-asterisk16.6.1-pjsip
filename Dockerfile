FROM ubuntu:bionic
MAINTAINER Asongwz 

ENV ASTERISKVERSION 16.6.1
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && \
    apt-get install --yes git curl wget openssl \
        sqlite3 pkg-config aptitude \
        libjansson-dev libssl-dev libedit-dev curl nano git msmtp libnewt-dev libssl-dev \
        libncurses5-dev subversion  libsqlite3-dev build-essential libjansson-dev libxml2-dev  uuid-dev && \
    apt-get install --yes aptitude-common libboost-filesystem1.65.1 libboost-iostreams1.65.1 \
  			libboost-system1.65.1 libcgi-fast-perl libcgi-pm-perl libclass-accessor-perl \
  			libcwidget3v5 libencode-locale-perl libfcgi-perl libhtml-parser-perl \
  			libhtml-tagset-perl libhttp-date-perl libhttp-message-perl libio-html-perl \
  			libio-string-perl liblwp-mediatypes-perl libparse-debianchangelog-perl \
  			libsigc++-2.0-0v5 libsub-name-perl libtimedate-perl liburi-perl libxapian30 \
  	&& apt-get purge -y --auto-remove $buildDeps

WORKDIR /usr/src
# Download asterisk
RUN curl -o asterisk.tar.gz http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISKVERSION}.tar.gz  && \
		tar xvzf asterisk.tar.gz && rm -f asterisk-${ASTERISKVERSION}.tar.gz && mv asterisk-16* asterisk 	

WORKDIR /usr/src/asterisk

RUN contrib/scripts/get_mp3_source.sh \
		&& contrib/scripts/install_prereq install 

RUN apt-get purge -y --auto-remove $buildDeps

WORKDIR /usr/src/asterisk
RUN ./configure \
    && make menuselect.makeopts \
    && menuselect/menuselect \
    --enable BETTER_BACKTRACES \
    --enable DONT_OPTIMIZE \
    --disable BUILD_NATIVE \
    --disable chan_sip 
    
RUN make && make install \
    && make samples \
    && make config \
    && ldconfig 

RUN groupadd asterisk \
		&& useradd -r -d /var/lib/asterisk -g asterisk asterisk \
		&& usermod -aG audio,dialout asterisk \
		&& chown -R asterisk.asterisk /etc/asterisk \
		&& chown -R asterisk.asterisk /var/lib/asterisk \
		&& chown -R asterisk.asterisk /var/log/asterisk \
		&& chown -R asterisk.asterisk /var/spool/asterisk \
		&& chown -R asterisk.asterisk /usr/lib/asterisk \
		&& sed -i 's/#AST_USER="asterisk"/AST_USER="asterisk"/g' /etc/default/asterisk \
		&& sed -i 's/#AST_GROUP="asterisk"/AST_GROUP="asterisk"/g' /etc/default/asterisk \
		&& sed -i 's/;runuser = asterisk/runuser = asterisk/g' /etc/asterisk/asterisk.conf \
		&& sed -i 's/;rungroup = asterisk/rungroup = asterisk/g' /etc/asterisk/asterisk.conf 
		
COPY config/extensions.conf /etc/asterisk/
COPY config/pjsip.conf /etc/asterisk/
COPY config/startup.sh /root/startup.sh
COPY config/http.conf /etc/asterisk/
COPY config/rtp.conf /etc/asterisk/

EXPOSE 5060/udp
EXPOSE 10000-10050/udp

ENTRYPOINT ["/bin/bash", "/root/startup.sh"]
		
		
		
		
		