FROM ubuntu:16.04

LABEL de.mindrunner.android-docker.flavour="ubuntu-standalone"

ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux

ENV DEBIAN_FRONTEND noninteractive

# Install required tools
# Dependencies to execute Android builds

RUN dpkg --add-architecture i386 && apt-get update -yqq && apt-get install -y \
  curl \
  expect \
  git \
  libc6:i386 \
  libgcc1:i386 \
  libncurses5:i386 \
  libstdc++6:i386 \
  zlib1g:i386 \
  openjdk-8-jdk \
  wget \
  unzip \
  vim \
  && apt-get clean

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android && \
        useradd -d /opt/android-sdk-linux -g android sdswci1 && \
        useradd -d /opt/android-sdk-linux -g android sdswci2 && \
        useradd -d /opt/android-sdk-linux -g android sdswci3

COPY . /opt/

COPY licenses /opt/

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh lazy-dl

CMD /opt/tools/entrypoint.sh lazy-dl

