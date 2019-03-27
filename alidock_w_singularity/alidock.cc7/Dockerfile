FROM alisw/alidock:latest

LABEL MAINTAINER "Yasser Corrales Morales ycorrale@cern.ch"

RUN yum install -y libarchive-devel squashfs-tools && \
    rm -rf /var/cache/yum/*
RUN cd /tmp && \
    git clone https://github.com/sylabs/singularity.git && \
    cd singularity && \
    git fetch --all && \
    git checkout 2.5.0 && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd .. && \
    rm -rf singul*
