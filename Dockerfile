FROM quay.io/centos/centos:stream9

WORKDIR /home/coder
USER root
RUN yum -y clean all && yum -y update
RUN yum -y install epel-release
RUN yum -y install wget gcc htop man nano vim emacs vim-common less tree zip unrar-free p7zip p7zip-plugins iputils dnsutils graphviz \
        openssh-clients jq wireshark-cli openssl-devel bzip2-devel libffi-devel snappy lz4-devel python3-pip bsdtar zlib-devel pylint nodejs \
        tmux unzip dirmngr gnupg ca-certificates yarnpkg ghostscript cmake 
RUN yum -y groupinstall "Development Tools"

# Python 3.11 Install
RUN cd /usr/src \
        && wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz \
        && tar -xzf Python-3.11.0.tgz \
        && cd Python-3.11.0 \
        && ./configure --enable-optimizations \
        && make altinstall

RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 20

# Code-Server Install
RUN mkdir -p ~/.local/lib ~/.local/bin
RUN curl -fL https://github.com/coder/code-server/releases/download/v4.14.1/code-server-4.14.1-linux-amd64.tar.gz \
        | tar -C ~/.local/lib -xz
RUN mv ~/.local/lib/code-server-4.14.1-linux-amd64 ~/.local/lib/code-server-4.14.1
RUN ln -s ~/.local/lib/code-server-4.14.1/bin/code-server ~/.local/bin/code-server
ENV PATH="~/.local/bin:$PATH"

# PIP Installs
RUN pip install jupyter jupyterhub ipywidgets widgetsnbextension jupyterlab-git s3cmd pylint s3transfer dotbot yara

# VSCode extensions
RUN mkdir -p /home/coder/.code-server/extensions

# VC Python
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/2023.11.11781018/vspackage | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/ms-python-release

# VC Docker
RUN curl -JL https://github.com/microsoft/vscode-docker/releases/download/v1.25.1/vscode-docker-1.25.1.vsix | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/vscode-docker-1.25.1

# VC Icons
RUN curl -JL https://github.com/vscode-icons/vscode-icons/releases/download/v12.4.0/vscode-icons-12.4.0.vsix | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/vscode-icons-12.4.0

# VC YAML
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/icsharpcode/vsextensions/ilspy-vscode/0.15.0/vspackage | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/ilspy-vscode-0.15.0

# VC YAML
RUN curl -JL https://github.com/redhat-developer/vscode-yaml/releases/download/1.13.0/yaml-1.13.0-19534.vsix | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/vscode-yaml-0.8.0

# VC Rest Client
RUN curl -JL https://github.com/Huachao/vscode-restclient/releases/download/v0.25.0/rest-client-0.25.0.vsix | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/rest-client-0.25.0

# VC Draw IO
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/hediet/vsextensions/vscode-drawio/1.6.6/vspackage | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/vscode-drawio-1.6.6

# VC Black Formatter
COPY ms-python.black-formatter-2023.3.11731009.vsix ms-python.black-formatter-2023.3.11731009.vsix
RUN bsdtar -xvf ms-python.black-formatter-2023.3.11731009.vsix extension && \
        mv extension /home/coder/.code-server/extensions/black-formatter-release && \
        rm -f ms-python.black-formatter-2023.3.11731009.vsix

# VC TOML
COPY be5invis.toml-0.6.0.vsix be5invis.toml-0.6.0.vsix
RUN bsdtar -xvf be5invis.toml-0.6.0.vsix extension && \
        mv extension /home/coder/.code-server/extensions/toml-0.6.0 && \
        rm -f be5invis.toml-0.6.0.vsix

# VC GO
RUN curl -JL https://github.com/golang/vscode-go/releases/download/v0.39.0/go-0.39.0.vsix | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/go-0.39.0

# VC Regex Previewer
COPY chrmarti.regex-0.4.0.vsix chrmarti.regex-0.4.0.vsix
RUN bsdtar -xvf chrmarti.regex-0.4.0.vsix extension && \
        mv extension /home/coder/.code-server/extensions/regex-0.4.0 && \
        rm -f chrmarti.regex-0.4.0.vsix

# VC Bookmarks
RUN curl -JL https://github.com/alefragnani/vscode-bookmarks/releases/download/v13.0.1/Bookmarks-13.0.1.vsix | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/bookmarks-13.0.1

# VC Python Preview
COPY dongli.python-preview-0.0.4.vsix dongli.python-preview-0.0.4.vsix
RUN bsdtar -xvf dongli.python-preview-0.0.4.vsix extension && \
        mv extension /home/coder/.code-server/extensions/python-preview-0.0.4 && \
        rm -f dongli.python-preview-0.0.4.vsix

# VC Better Comments
COPY aaron-bond.better-comments-3.0.2.vsix aaron-bond.better-comments-3.0.2.vsix
RUN bsdtar -xvf aaron-bond.better-comments-3.0.2.vsix extension && \
        mv extension /home/coder/.code-server/extensions/better-comments-3.0.2 && \
        rm -f aaron-bond.better-comments-3.0.2.vsix

# VC Python Test Adapter
RUN curl -JL https://github.com/kondratyev-nv/vscode-python-test-adapter/releases/download/v0.7.1/vscode-python-test-adapter-0.7.1.vsix | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/vscode-python-test-adapter-0.7.1

# VC Python Snippets
COPY cstrap.python-snippets-0.1.2.vsix cstrap.python-snippets-0.1.2.vsix
RUN bsdtar -xvf cstrap.python-snippets-0.1.2.vsix extension && \
        mv extension /home/coder/.code-server/extensions/python-snippets-0.1.2 && \
        rm -f cstrap.python-snippets-0.1.2.vsix

# VC Kuberenets Tools
RUN curl -JL https://github.com/vscode-kubernetes-tools/vscode-kubernetes-tools/releases/download/1.3.13/vscode-kubernetes-tools-1.3.13.vsix | bsdtar -xvf - extension && mv extension /home/coder/.code-server/extensions/vscode-kubernetes-tools-1.3.13

ENV PATH="/root/.local/lib/code-server-4.14.1/bin:$PATH"

RUN yum -y install passwd

RUN useradd coder && passwd -f -u coder
RUN chown -R coder:coder /home/coder/.code-server
USER coder
RUN mkdir -p /home/coder/.code-server/User/workspaceStorage
WORKDIR /home/coder

USER root

ENV SHELL=/bin/bash

ENV LANG=en_US.UTF-8

EXPOSE 8080

CMD ["code-server", "--bind-addr=0.0.0.0:8080", "--disable-telemetry", "--auth=none", "--user-data-dir=/home/coder.code-server", "."]
