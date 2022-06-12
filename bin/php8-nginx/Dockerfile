FROM php:8.1-fpm

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844
 
ARG DEBIAN_FRONTEND=noninteractive

# Update
RUN apt-get -y update --fix-missing && \
    apt-get upgrade -y && \
    apt-get --no-install-recommends install -y apt-utils


# Install useful tools and install important libaries
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install nano wget dialog libsqlite3-dev libsqlite3-0 && \
    apt-get -y --no-install-recommends install default-libmysqlclient-dev zlib1g-dev libzip-dev libicu-dev && \
    apt-get -y --no-install-recommends install --fix-missing apt-utils build-essential git curl && \ 
    apt-get -y --no-install-recommends install --fix-missing libcurl4-openssl-dev zip openssl && \
    apt-get -y --no-install-recommends install nginx && \
    apt-get -y --no-install-recommends install supervisor gettext-base && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Install xdebug
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

# Install redis
RUN pecl install redis && \
    docker-php-ext-enable redis

# Other PHP7 Extensions

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pdo_sqlite
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install gettext

# Install Freetype 
RUN apt-get -y update && \
    apt-get --no-install-recommends install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd

# Install SSH access
ENV SSHUSER remote
ENV SSHGROUP remote

RUN apt-get -y update && \
    apt-get --no-install-recommends install -y openssh-server sudo && \
    rm -rf /var/lib/apt/lists/* 
# Create a user "docker" and group "remote"
RUN groupadd ${SSHGROUP} && useradd -ms /bin/bash -g ${SSHGROUP} ${SSHUSER}
# Create sshuser directory in home
RUN mkdir -p /home/${SSHUSER}/.ssh
# Add as sudoers
RUN sed -i -e 's/\s*Defaults\s*secure_path\s*=/# Defaults secure_path=/' /etc/sudoers
RUN echo "${SSHUSER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
# Copy the ssh public key in the authorized_keys file. The idkey.pub below is a public key file you get from ssh-keygen. They are under ~/.ssh directory by default.
COPY idkey.pub /home/${SSHUSER}/.ssh/authorized_keys
# change ownership of the key file. 
RUN chown ${SSHUSER}:${SSHGROUP} /home/${SSHUSER}/.ssh/authorized_keys && chmod 600 /home/${SSHUSER}/.ssh/authorized_keys
# Start SSH service
RUN service ssh start

# install NodeJs
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NODE_VERSION 14.19.1
ENV NVM_DIR "/root/.nvm"
RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" &&  nvm use v${NODE_VERSION}
RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

RUN cp $NVM_DIR/versions/node/v${NODE_VERSION}/bin/node /usr/bin/
RUN cp $NVM_DIR/versions/node/v${NODE_VERSION}/bin/npm /usr/bin/

# add configurations
COPY rootfs /

# Cleanup
RUN rm -rf /usr/src/*

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# ports
EXPOSE 80 22