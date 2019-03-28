
FROM centos:7


LABEL maintainer="labeg@mail.ru" \
      io.k8s.description="Headless VNC Container with LXQt Desyktop manager" \
      io.k8s.display-name="Headless VNC Container based on Centos" \
      io.openshift.expose-services="6901:http,5901:xvnc" \
      io.openshift.tags="vnc, centos, xfce" \
      io.openshift.non-scalable=true


ENV HOME=/home/headless


RUN yum install -y epel-release dnf \
        && \
        dnf install -y \
            tigervnc-server \
            openbox obconf-qt \
            xterm htop nano gnome-system-monitor expect \
            lxqt-about lxqt-common lxqt-config lxqt-globalkeys lxqt-notificationd lxqt-openssh-askpass lxqt-panel lxqt-policykit lxqt-qtplugin lxqt-runner lxqt-session network-manager-applet nm-connection-editor pcmanfm-qt \
        && \
        yum clean all && dnf clean all \
        && \
        rm -rf /var/cache/yum/* && rm -rf /var/cache/dnf/*
# 202MB 428MB 597MB 765MB


RUN /bin/dbus-uuidgen --ensure && \
        useradd headless && \
        mkdir -p ${HOME}/.vnc && \
        echo '#!/bin/sh' > ${HOME}/.vnc/xstartup && \
        echo 'exec startlxqt' >> ${HOME}/.vnc/xstartup \
        && \
        echo '#!/usr/bin/expect' > ${HOME}/startup.sh && \
        echo 'spawn /usr/bin/vncserver -fg' >> ${HOME}/startup.sh && \
        echo 'expect "Password:"' >> ${HOME}/startup.sh && \
        echo 'send "$env(password)\r"' >> ${HOME}/startup.sh && \
        echo 'expect "Verify:"' >> ${HOME}/startup.sh && \
        echo 'send "$env(password)\r"' >> ${HOME}/startup.sh && \
        echo 'expect "Would you like to enter a view-only password (y/n)?"' >> ${HOME}/startup.sh && \
        echo 'send "n\r"' >> ${HOME}/startup.sh && \
        echo 'expect eof' >> ${HOME}/startup.sh && \
        echo 'wait' >> ${HOME}/startup.sh \
        && \
        chmod 777 -R ${HOME}


WORKDIR ${HOME}
USER headless
ENTRYPOINT ["./startup.sh"]