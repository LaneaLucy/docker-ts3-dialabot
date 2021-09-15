FROM jgoerzen/debian-base-minimal:latest

RUN apt update

RUN DEBIAN_FRONTEND=noninteractive apt -y install keyboard-configuration

RUN DEBIAN_FRONTEND=noninteractive apt -y install \
        xvfb \
#        xserver-xorg-video-dummy xserver-xorg-input-libinput xinit x11-xserver-utils \
        x11vnc pulseaudio \
#        wget \  # things we need for ts
        libnss3 libxcursor1 libxss1 libpci3 libasound2 libxslt1.1 libxcomposite1 qt5dxcb-plugin

#RUN wget https://files.teamspeak-services.com/releases/client/3.5.6/TeamSpeak3-Client-linux_amd64-3.5.6.run
#RUN chmod +x TeamSpeak3-Client-linux_amd64-3.5.6.run
#RUN ./TeamSpeak3-Client-linux_amd64-3.5.6.run
    
COPY *.service /etc/systemd/system/

COPY systemd_import_var.sh /usr/local/preinit/
    
COPY --chown=pulse:pulse system.pa /etc/pulse/

    # Configure pulseaudio system mode
RUN systemctl enable pulseaudio
#RUN useradd -r -U -G audio -m -d /var/run/pulse -c "PulseAudio" -s /bin/false pulse
#RUN groupadd -r pulse-access
    # Configure teamspeak user
RUN useradd -m -G pulse-access teamspeak
RUN mkdir /home/teamspeak/.ts3client
RUN chown teamspeak:teamspeak /home/teamspeak/.ts3client
RUN chmod og+rwx /home/teamspeak/.ts3client

COPY TeamSpeak3-Client-linux_amd64 /usr/ts3client
RUN chown -R teamspeak:teamspeak /usr/ts3client/
RUN chmod -R og+x /usr/ts3client/

RUN systemctl enable teamspeak3 ts3vnc

ENV PULSE_RUNTIME_PATH=/var/run/pulse
#ENV PULSE_RUNTIME_PATH=/run/pulse
ENV TS_NICKNAME="testi4"

VOLUME [ "/home/teamspeak/.ts3client" ]

