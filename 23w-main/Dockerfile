FROM ubuntu

# TODO: Replace value of CI_PROJECT_NAME with team name
ENV CI_PROJECT_NAME='svs10'
ENV CI_PROJECT_NAMESPACE='web'
ENV DEBIAN_FRONTEND='noninteractive'
ENV TZ=Europe/Berlin
LABEL authors='Michael.Deichen@haw-hamburg.de'

RUN apt-get update && apt-get install -y \
        apache2 \
        curl \
        gettext \
        less \
        libintl-perl \
        lynx \
        nano \
        net-tools \
        openssh-server \
        tcpdump \
        telnet \
        tzdata \
        wget \
        openssl \
&& rm -rf /var/lib/apt/lists/*

# locale
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Setup ssh
RUN mkdir /var/run/sshd
# allow root login with key pair
RUN sed -i 's/#Port 22/Port 222/' /etc/ssh/sshd_config
# allow root login with key pair
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin\ prohibit-password/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
ENV NOTVISIBLE='in users profile'
RUN echo 'export VISIBLE=now' >> /etc/profile

COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 0400 /root/.ssh/authorized_keys
COPY userdata /userdata

# Add welcome message
RUN echo 'Welcome to our web portal from '${CI_PROJECT_NAME}'.' > /etc/motd

# Copy cert.sh and make it executable
COPY cert.sh /usr/local/bin/cert.sh
RUN chmod +x /usr/local/bin/cert.sh

# Run cert.sh to create certificates
RUN /usr/local/bin/cert.sh

# Apache
COPY certs/svs10.ful.informatik.haw-hamburg.de.crt /etc/svs10.ful.informatik.haw-hamburg.de.crt
COPY certs/svs10.ful.informatik.haw-hamburg.de.key /etc/svs10.ful.informatik.haw-hamburg.de.key
COPY certs/chain.crt /etc/chain.crt
COPY certs/chain-user.crt /etc/chain-user.crt
COPY apache2-user-config.conf /etc/apache2/sites-available/webportal.conf
COPY config/.htpasswd /etc/apache2/.htpasswd

RUN /bin/bash -c 'envsubst < /etc/apache2/sites-available/webportal.conf | tee /etc/apache2/sites-available/webportal.conf'
RUN /bin/bash -c 'envsubst < /userdata/webportal/index.html | tee /userdata/webportal/index.html'

ADD certs certs/userdata

RUN a2dissite 000-default.conf
RUN a2dissite default-ssl.conf
RUN a2ensite webportal.conf
RUN a2enmod ssl
# RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
# RUN apache2ctl start

# autorun
RUN /bin/bash /userdata/autorun.sh

EXPOSE 222
EXPOSE 80
EXPOSE 443

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
CMD ["./entrypoint.sh"]
