FROM debian:bookworm 

# Install generic requirements
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    unzip \
    curl \
    pkg-config \
    ca-certificates \
    gnupg \
    software-properties-common \
    wget \
    gedit \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=ros
ARG USER_UID=1002
ARG USER_GID=1002
#ARG USER_GID=$USER_UID

#Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config

# Set up sudo
RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Need to create a sources.list file for apt-add-repository to work correctly:
# https://groups.google.com/g/linux.debian.bugs.dist/c/6gM_eBs4LgE
RUN echo "# See sources.lists.d directory" > /etc/apt/sources.list

# Add Raspberry Pi repository, as this is where we will get the Hailo deb packages
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 82B129927FA3303E && \
    apt-add-repository -y -S deb http://archive.raspberrypi.com/debian/ bookworm main

# Dependencies for hailo-tappas-core
RUN apt-get install -y python3 ffmpeg x11-utils python3-dev python3-pip \
    python3-setuptools gcc-12 g++-12 python-gi-dev pkg-config libcairo2-dev \
    libgirepository1.0-dev libgstreamer1.0-dev cmake \
    libgstreamer-plugins-base1.0-dev libzmq3-dev rsync git \
    libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav \
    gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-libcamera libopencv-dev \
    python3-opencv python3-numpy libboost-python-dev

# Dependencies for rpicam-apps-hailo-postprocess
RUN apt-get install -y rpicam-apps hailo-tappas-core-3.28.2
# Excludes hailort as it fails to install during build stage

# Dependencies for hailo-rpi5-examples
RUN apt-get install -y python3-venv meson

# Installing Tkinter 
RUN apt-get install -y python3-tk

# Download Raspberry Pi examples
RUN git clone --depth 1 https://github.com/raspberrypi/rpicam-apps.git

# Download ros2 jazzy
# RUN wget https://s3.ap-northeast-1.wasabisys.com/download-raw/dpkg/ros2-desktop/debian/bookworm/ros-iron-desktop-0.3.2_20231028_arm64.deb \
#     && apt install -y ./ros-iron-desktop-0.3.2_20231028_arm64.deb \
#     && pip install --break-system-packages empy==3.3.4 \
#     && pip install --break-system-packages vcstool colcon-common-extensions

# Download ros2 jazzy
RUN wget https://github.com/Ar-Ray-code/rpi-bullseye-ros2/releases/download/ros2-0.3.2/ros-jazzy-desktop-0.3.2_20240525_arm64.deb \
    && apt install -y ./ros-jazzy-desktop-0.3.2_20240525_arm64.deb \
    && pip install --break-system-packages empy==3.3.4 \
    && pip install --break-system-packages vcstool colcon-common-extensions

# Hailo    
WORKDIR /home/ros
USER ros
RUN git clone https://github.com/hailo-ai/hailo-rpi5-examples.git 
WORKDIR /home/ros/hailo-rpi5-examples
RUN git clone https://github.com/LichtenbergCode/drone-tello-leader-follower-vision.git

# ROS OpenCV
WORKDIR /home/ros/vision_opencv/src
RUN git clone https://github.com/ros-perception/vision_opencv.git -b iron

# ROS Interfaces
WORKDIR /home/ros/drone_det_itfc/src
RUN git clone https://github.com/LichtenbergCode/drone-tello-leader-follower-interfaces.git

# GUI/ Control 
WORKDIR /home/ros
RUN git clone https://github.com/LichtenbergCode/tello-leader-follower.git 

WORKDIR /home

CMD ["bash"]