FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive

#Set User Path with expected paths for new packages
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/usr/local/go:/usr/local/go/dev/bin:/usr/local/bin/python3:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.local/bin:${PATH}"
ENV PATHVAR="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/usr/local/go:/usr/local/go/dev/bin:/usr/local/bin/python3:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.local/bin:${PATH}"

#Install needed packages as well as setup python with args and pip
RUN mkdir -p /azp && \
    apt-get update -y && apt-get dist-upgrade -y && apt-get install -y \
    apt-transport-https \
    bash \
    build-essential \
    libbz2-dev \
    ca-certificates \
    curl \
    gcc \
    gnupg \
    gnupg2 \
    gpg \
    git \
    jq \
    libffi-dev \
    libicu-dev \
    locales \
    make \
    nano \
    sudo  \
    software-properties-common \
    terminator \
    libsqlite3-dev \
    libssl-dev\
    unzip \
    wget \
    zip  \
    zlib1g-dev && \
                useradd -m -s /bin/bash linuxbrew && \
                usermod -aG sudo linuxbrew &&  \
                mkdir -p /home/linuxbrew/.linuxbrew && \
                chown -R linuxbrew: /home/linuxbrew/.linuxbrew && \
    wget -q https://packages.microsoft.com/config/ubuntu/$(grep -oP '(?<=^DISTRIB_RELEASE=).+' /etc/lsb-release | tr -d '"')/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
    rm -f packages.microsoft.gpg && \
     curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/ && \
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-beta.list' && \
    sudo rm microsoft.gpg && \
    sudo apt-get update && \
    sudo apt-get install microsoft-edge-beta -y && \
    apt-get update && apt-get install code && apt-get autoremove

COPY install-jetbrains-toolbox.sh /usr/bin/
RUN chmod +x /usr/bin/install-jetbrains-toolbox.sh && ./usr/bin/install-jetbrains-toolbox.sh

RUN echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list && \
curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/Release.key" | apt-key add - && \
apt-get update && \
apt-get -y upgrade && \
apt-get -y install container-tools && \
apt-get install -y crun podman  fuse-overlayfs

RUN useradd podman; \
echo podman:10000:5000 > /etc/subuid; \
echo podman:10000:5000 > /etc/subgid;

VOLUME /var/lib/containers
RUN mkdir -p /home/podman/.local/share/containers
RUN chown podman:podman -R /home/podman
VOLUME /home/podman/.local/share/containers

#https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/containers.conf
ADD containers.conf /etc/containers/containers.conf
#https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/podman-containers.conf
ADD podman-containers.conf /home/podman/.config/containers/containers.conf

ADD storage.conf /etc/containers/storage.conf

#chmod containers.conf and adjust storage.conf to enable Fuse storage.
RUN chmod 644 /etc/containers/containers.conf; sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers /var/lib/shared/vfs-images /var/lib/shared/vfs-layers; \
    touch /var/lib/shared/overlay-images/images.lock; \
    touch /var/lib/shared/overlay-layers/layers.lock; \
    touch /var/lib/shared/vfs-images/images.lock; \
    touch /var/lib/shared/vfs-layers/layers.lock

ENV _CONTAINERS_USERNS_CONFIGURED=""

#Install Azure Modules for Powershell - This can take a while, so setting as final step to shorten potential rebuilds
RUN pwsh -Command Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted ; pwsh -Command Install-Module -Name Az -Force -AllowClobber -Scope AllUsers -Repository PSGallery

RUN echo ${PATHVAR} | tee /etc/environment

##Set as unpriviledged user for default container execution
USER linuxbrew

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/linuxbrew/.bash_profile && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/linuxbrew/.bashrc && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

RUN brew install gcc tfenv azure-cli python3 tfsec terraform-docs openjdk yq && tfenv install latest && tfenv use latest
RUN cd /home/linuxbrew/ && brew tap kwilczynski/homebrew-pkenv && \
    brew install pkenv && pkenv install latest

RUN pip3 install pipx && \
    pipx install terraform-compliance && \
    pipx install checkov && \
    pipx install ansible-core && \
    pipx install podman-compose

USER root

RUN apt-get install -y \
    xfce4 \
    xfce4-clipman-plugin \
    xfce4-cpugraph-plugin \
    xfce4-netload-plugin \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-terminal \
    xfce4-xkb-plugin

RUN apt-get install -y \
    sudo \
    wget \
    xorgxrdp \
    xrdp && \
    apt-get remove -y light-locker xscreensaver && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt /var/lib/apt/lists

COPY run.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh

# https://github.com/danielguerra69/ubuntu-xrdp/blob/master/Dockerfile
RUN mkdir /var/run/dbus && \
    cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
    sed -i "s/console/anybody/g" /etc/X11/Xwrapper.config && \
    sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
    echo "xfce4-session" >> /etc/skel/.Xsession

# Docker config
EXPOSE 3389
ENTRYPOINT ["/usr/bin/run.sh"]

