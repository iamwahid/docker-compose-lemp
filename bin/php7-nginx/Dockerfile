FROM php:7.3-fpm

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844
 
ARG DEBIAN_FRONTEND=noninteractive

# Update
RUN apt-get -y update --fix-missing && \
    apt-get upgrade -y && \
    apt-get --no-install-recommends install -y apt-utils && \
    rm -rf /var/lib/apt/lists/*


# Install useful tools and install important libaries
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install nano wget dialog libsqlite3-dev libsqlite3-0 && \
    apt-get -y --no-install-recommends install default-libmysqlclient-dev zlib1g-dev libzip-dev libicu-dev && \
    apt-get -y --no-install-recommends install --fix-missing apt-utils build-essential git curl && \ 
    apt-get -y --no-install-recommends install --fix-missing libcurl4-openssl-dev zip openssl && \
    apt-get -y --no-install-recommends install nginx && \
    apt-get -y --no-install-recommends install supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Install xdebug
RUN pecl install xdebug-2.7.2 && \
    docker-php-ext-enable xdebug

# Install redis
RUN pecl install redis-5.0.2 && \
    docker-php-ext-enable redis

# Other PHP7 Extensions

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_sqlite && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install curl && \
    docker-php-ext-install tokenizer && \
    docker-php-ext-install json && \
    docker-php-ext-install zip && \
    docker-php-ext-install -j$(nproc) intl && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install gettext

# Install Freetype 
RUN apt-get -y update && \
    apt-get --no-install-recommends install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
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

# install NPM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
# ENV NVM_DIR "$HOME/.nvm"
# RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
#     [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
# RUN nvm install 14

# add supervisord configuration
COPY rootfs /

# Cleanup
RUN rm -rf /usr/src/*

# ports
EXPOSE 80 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]