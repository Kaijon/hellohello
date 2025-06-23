FROM eclipse-temurin:11.0.14.1_1-jdk-focal AS jre-build

# Generate smaller java runtime without unneeded files
# for now we include the full module path to maintain compatibility
# while still saving space (approx 200mb from the full distribution)
RUN jlink \
         --add-modules ALL-MODULE-PATH \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime

FROM debian:bullseye-20220328

ARG VERSION=4.13
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}
LABEL Description="This is a base image, which provides the Jenkins agent executable (agent.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

RUN apt-get update \
  && apt-get -y install \
    curl \
    net-tools \
    iputils-ping \
    python3-pip \
    libxml2-dev \
    libudev-dev \
    ffmpeg \
    python3-opencv \
    git \
    vim \
    nmap \
    unzip \
    libmagic-dev \
    html2text \
    sshpass \
    sudo \
  && curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar \
  && mkdir -p /usr/local/android-sdk \
  && cd /usr/local/android-sdk/ \
  && curl -OL https://dl.google.com/android/repository/platform-tools_r27.0.0-linux.zip \
  && unzip platform-tools_r27.0.0-linux.zip \
  && rm -f platform-tools_r27.0.0-linux.zip \
  && ln -s /usr/local/android-sdk/platform-tools/adb /usr/bin/adb \
  && export PATH=/usr/local/android-sdk/platform-tools:${PATH} \
  && echo "export PATH=/usr/local/android-sdk/platform-tools:${PATH}" >> /etc/profile \
  && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip
RUN pip install pipenv && \
    pip install -U setuptools==57.5.0
RUN usermod -aG sudo ${user}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV LANG C.UTF-8

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:/home/${user}/.local/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

RUN pip install --upgrade pip && \
    pip install pipenv && \
    pip install -U setuptools==57.5.0

RUN git config --global http.sslverify false
RUN cd /home/${user} && \
    git clone https://git.linaro.org/landing-teams/working/qualcomm/qdl.git && \
    cd qdl && \
    make
