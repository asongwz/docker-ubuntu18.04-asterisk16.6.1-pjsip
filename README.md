# docker-ubuntu18.04-asterisk16.6.1-pjsip
You can find this image on the docker hub at: https://hub.docker.com/repository/docker/asongwz/ubuntu18.04-asterisk
Docker image with Certified Asterisk 16.6.1 LTS version and Ubuntu 64bits (18.04 LTS)
This is the Docker latest Asterisk 16.6.1 version on Ubuntu X86_64 PJSIP version 2.9.0.

Includes:

Asterisk 16.6.1
pjsip 2.9.0 channel enabled
To pull it:

# docker pull asongwz/docker-ubuntu18.04-asterisk16.6.1-pjsip

For compile it on your own platform/server from the Dockerfile:

$ git clone https://github.com/asongwz/docker-ubuntu18.04-asterisk16.6.1-pjsip

$ cd docker-ubuntu18.04-asterisk16.6.1-pjsip

$ docker build -t myrepository/asterisk01 .

[or you can modify externalip by:
$ docker build --build-arg IP=[yourip] -f Dockerfile_modify_externalIP -t myrepository/asterisk01 .
]
To execute it:

Asterisk PBX needs to use a big range of ports, so it needs to be executed with docker version 1.5.0 or higher (available in docker ubuntu sources) for being able to launch the image specifying a range of ports. For example:

# docker run --restart=always --privileged --name asterisk01 -d -p 5060:5060 -p 5060:5060/udp -p 10000-10050:10000-10050/udp 

and connect to asterisk CLI with:

# docker exec -it asterisk01 

Notice:

Seems that opening too much ports in a docker images, consumes a lot of resources in your docker host and may fail to launch it. So giving that every SIP call can use up to 4 RTP ports, it is convenient to open only the necessary RTP ports for the expected calls. In this case we open 500 RTP ports for 125 expected concurrent calls. From 10000 to 10500. Don't forget to configure that RTP ports in the /etc/asterisk/rtp.conf file:

# rtpstart=10000
# rtpend=10050

To manage ubuntu, login to asterisk container:

# docker exec -it asterisk01 bash
