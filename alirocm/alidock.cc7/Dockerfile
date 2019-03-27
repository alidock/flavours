FROM alisw/alidock:latest

LABEL MAINTAINER "Matteo Concas mconcas@cern.ch"

# https://gitlab.com/nvidia/cuda/blob/centos7/9.2/base/Dockerfile
# RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
#     curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/7fa2af80.pub | sed '/^Version/d' > /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA && \
#     echo "$NVIDIA_GPGKEY_SUM  /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA" | sha256sum -c --strict -

COPY rocm.repo /etc/yum.repos.d/rocm.repo


RUN yum install -y             \
    rocm-dev                && \
    rm -rf /var/cache/yum/*

ENV PATH "${PATH}:/opt/rocm/bin"
ENV PATH "${PATH}:/opt/rocm/opencl/bin"
