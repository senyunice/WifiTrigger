FROM ubuntu:20.04

# 设置apt源为国内镜像
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    zip \
    unzip \
    git \
    wget \
    python3 \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install ldid from source
RUN git clone https://github.com/xerub/ldid.git /tmp/ldid && \
    cd /tmp/ldid && \
    make && \
    cp ldid /usr/local/bin/ && \
    chmod +x /usr/local/bin/ldid

# Install Theos
RUN git clone --recursive https://github.com/theos/theos.git /opt/theos

ENV THEOS=/opt/theos
ENV PATH=$THEOS/bin:$PATH

# Install iOS SDK
RUN cd /tmp && \
    wget -q https://github.com/ios-cross/iphonesdk-fake/releases/download/v17.0.0/iPhoneOS15.6.sdk.tar.xz && \
    tar -xf iPhoneOS15.6.sdk.tar.xz && \
    mv iPhoneOS15.6.sdk /opt/theos/sdks/

WORKDIR /project

# Copy the project files
COPY . /project

CMD ["bash", "-c", "export THEOS=/opt/theos && make clean package FINALPACKAGE=1"]