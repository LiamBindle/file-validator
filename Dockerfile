FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    build-essential \
    libhdf5-dev \
    nco \
    openmpi-bin libopenmpi-dev \
    rsync \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*


RUN wget https://support.hdfgroup.org/ftp/HDF5/tools/h5check/src/h5check-2.0.1.tar.gz \
&&  tar -xvzf h5check* \
&&  rm h5check*.tar.gz

RUN cd h5check* \
&&  ./configure --prefix=/usr \
&&  make \
&&  make install \
&& rm -rf /h5check*

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    git \
    cmake \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/LiamBindle/batch_exec.git \
&&  cd batch_exec \
&&  mkdir build \
&&  cd build \
&&  cmake -DCMAKE_INSTALL_PREFIX=/usr .. \
&&  make -j install

COPY check-file.sh /check-file.sh