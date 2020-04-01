FROM ubuntu:19.04

# Packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    gpg \
    curl \
    wget \
    lsb-release \
    add-apt-key \
    ca-certificates \
    dumb-init \
    htop \
    locales \
    man \
    && rm -rf /var/lib/apt/lists/*

# Helm CLI
RUN curl "https://raw.githubusercontent.com/helm/helm/master/scripts/get" | bash

# Kubectl CLI
RUN curl -sL "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Common SDK
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    sudo \
    gdb \
    pkg-config \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Node 10.x SDK
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Golang 1.13 SDK
RUN curl -sL https://dl.google.com/go/go1.13.linux-amd64.tar.gz | tar -zx -C /usr/local

# Python SDK
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-pylint-common \
    && rm -rf /var/lib/apt/lists/*

# Chromium
RUN apt-get update && apt-get install --no-install-recommends -y \
    chromium-browser \
    && rm -rf /var/lib/apt/lists/*

# Code-Server
RUN apt-get update && apt-get install --no-install-recommends -y \
    bsdtar \
    openssl \
    locales \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV DISABLE_TELEMETRY true

ENV CODE_VERSION="2.1698-vsc1.41.1"
#RUN curl -sL https://github.com/cdr/code-server/releases/download/2.1698/code-server2.1698-vsc1.41.1-linux-x86_64.tar.gz | tar --strip-components=1 -zx -C /usr/local/bin code-server2.1698-vsc1.41.1-linux-x86_64/code-server
#RUN curl -sL https://github.com/cdr/code-server/releases/download/3.0.1/code-server-3.0.1-linux-x86_64.tar.gz | tar --strip-components=1 -zx -C /usr/local/bin code-server-3.0.1-linux-x86_64/code-server
RUN cd /tmp && wget https://github.com/cdr/code-server/releases/download/3.0.1/code-server-3.0.1-linux-x86_64.tar.gz && tar -xzf code-server*.tar.gz && rm code-server*.tar.gz && \
  mv code-server* /usr/local/lib/code-server && \
  ln -s /usr/local/lib/code-server/code-server /usr/local/bin/code-server

# Setup User
RUN groupadd -r diogo \
    && useradd -m -r diogo -g diogo -s /bin/bash \
    && echo "diogo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
USER diogo 

# Setup User Go Environment
ENV PATH "${PATH}:/usr/local/go/bin:/home/diogo/go/bin"

# Setup User Visual Studio Code Extentions
ENV VSCODE_USER "/home/diogo/.local/share/code-server/User"
ENV VSCODE_EXTENSIONS "/home/diogo/.local/share/code-server/extensions"

RUN mkdir -p ${VSCODE_USER}
COPY --chown=diogo:diogo settings.json /home/diogo/.local/share/code-server/User/

# Setup Go Extension
RUN mkdir -p ${VSCODE_EXTENSIONS}/go \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/Go/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/go extension

# Setup Python Extension
RUN mkdir -p ${VSCODE_EXTENSIONS}/python \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/python extension

# Setup Kubernetes Extension
RUN mkdir -p ${VSCODE_EXTENSIONS}/yaml \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/redhat/vsextensions/vscode-yaml/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/yaml extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/kubernetes \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-kubernetes-tools/vsextensions/vscode-kubernetes-tools/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/kubernetes extension

RUN helm init --client-only

# Setup Browser Preview
RUN mkdir -p ${VSCODE_EXTENSIONS}/browser-debugger \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/msjsdiag/vsextensions/debugger-for-chrome/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/browser-debugger extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/browser-preview \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/auchenberg/vsextensions/vscode-browser-preview/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/browser-preview extension

# Setup User Workspace
RUN mkdir -p /home/diogo/projects
WORKDIR /home/diogo/

COPY --chown=diogo:diogo examples /home/diogo/examples

EXPOSE 8080

ENTRYPOINT ["dumb-init", "--"]
CMD ["/usr/local/bin/code-server", "--auth", "none", "--disable-telemetry", "--port", "8080", "--host", "0.0.0.0"]
