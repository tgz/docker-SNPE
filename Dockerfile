FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive \
    GPG_KEY=C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF \
    PYTHON_VERSION=2.7.15 \
    PYTHON_PIP_VERSION=10.0.1 \
    CAFFE_DIR=/root/caffe SNPE_ROOT=/snpe

WORKDIR /root
VOLUME "/snpe"
SHELL ["/bin/bash", "-c"]

RUN set -xe \
		\
 		&& apt-get update \
 		&& apt-get -y install \
			libprotobuf-dev protobuf-compiler \ 
	 		wget zip git\
	 		libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev libboost-all-dev libatlas-base-dev \
	 		cmake \
	 		libgflags-dev libgoogle-glog-dev liblmdb-dev \
	 		python-software-properties software-properties-common \
 		\
    && apt-get install -y --no-install-recommends \
      tcl tk 

#python
RUN set -ex \
  && buildDeps=' \
    dpkg-dev \
    tcl-dev \
    tk-dev \
  ' \
  && apt-get install -y $buildDeps openssl libssl-dev --no-install-recommends \
  \
  && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
  && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
  && gpg --batch --verify python.tar.xz.asc python.tar.xz \
  && rm -rf "$GNUPGHOME" python.tar.xz.asc \
  && mkdir -p /usr/src/python \
  && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
  && rm python.tar.xz \
  \
  && cd /usr/src/python \
  && gnuArch="$(dpkg-architecture -qDEB_BUILD_GNU_TYPE)" \
  && ./configure \
    --build="$gnuArch" \
    --enable-shared \
    --with-shared \
    --enable-unicode=ucs4 \
    --enable-optimizations \
  && make -j "$(nproc)" \
  && make install \
  && ldconfig \
  \
  && apt-get purge -y --auto-remove $buildDeps \
  \
  && find /usr/local -depth \
    \( \
      \( -type d -a \( -name test -o -name tests \) \) \
      -o \
      \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
    \) -exec rm -rf '{}' + \
  && rm -rf /usr/src/python

RUN set -ex; \
  \
  wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
  \
  python get-pip.py \
    --disable-pip-version-check \
    --no-cache-dir \
    "pip==$PYTHON_PIP_VERSION" \
  ; \
  pip --version; \
  \
  find /usr/local -depth \
    \( \
      \( -type d -a \( -name test -o -name tests \) \) \
      -o \
      \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
    \) -exec rm -rf '{}' +; \
  rm -f get-pip.py

#Done with python
    
RUN set -ex \
	&& apt-get -y install python-numpy gfortran \
	&& pip install cython \
	&& pip install numpy==1.14.5 \
		sphinx==1.2.2 \
		scipy==1.1.0 \
		matplotlib==2.2.2 \
		scikit-image \
	protobuf==2.5.0 \
	pyyaml==3.10 \
	&& rm -rf /var/lib/apt/lists/*	\
  #basic env
  \
  # prepare caffe start
  && cd /root \
  && wget https://github.com/google/glog/archive/v0.3.3.tar.gz \
	  && tar zxvf v0.3.3.tar.gz \
	  && cd glog-0.3.3 \
	  && ./configure \
	  && make && make install \
	  \
  && cd /root \
  && wget https://github.com/schuhschuh/gflags/archive/master.zip \
	  && unzip master.zip \
	  && cd gflags-master \
	  && mkdir build \
 	&& cd build \
 	&& export CXXFLAGS="-fPIC" \
 	&& cmake .. \
 	&& make VERBOSE=1 \
 	&& make && make install \
	\
  && cd /root \
	&& git clone https://github.com/LMDB/lmdb && cd lmdb/libraries/liblmdb \
 	&& make && make install \
  \
  && cd /root \
  && git clone https://github.com/BVLC/caffe.git && cd caffe \
  && git reset --hard d8f79537977f9dbcc2b7054a9e95be00eb6f26d0 \
  && cp Makefile.config.example Makefile.config \
  && sed -i 's/^# CPU_ONLY := 1$/CPU_ONLY := 1/' Makefile.config \
  && make all \
  && make test \
  && make runtest \
  && make distribute \
  && make pycaffe \
  # end caffe build
  \
  && cd /snpe

CMD ["/bin/bash"]
