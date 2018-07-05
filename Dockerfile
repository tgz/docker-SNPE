FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /root
VOLUME "/snpe"

RUN set -xe \
		\
    #start basic env
 		&& apt-get update \
 		&& apt-get -y install python2.7 python2.7-dev python-pip \
			libprotobuf-dev protobuf-compiler \ 
	 		wget zip git\
	 		libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev libboost-all-dev libatlas-base-dev \
	 		cmake \
	 		libgflags-dev libgoogle-glog-dev liblmdb-dev \
	 		python-software-properties software-properties-common \
 		\
    #由于 ubuntu 14.04 安装 python2.7 只到 2.7.6，SSL版本太老，需要升级更新的版本
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys  5BB92C09DB82666C \
 		&& add-apt-repository -y ppa:fkrull/deadsnakes-python2.7 \
 		&& apt-get update \
 		&& apt-get -y upgrade \
 		&& apt-get -y install python-numpy gfortran \
 		&& pip install cython \
 		&& pip install numpy==1.8.1 \
				sphinx==1.2.2 \
				scipy==0.13.3 \
				matplotlib==1.3.1 \
				scikit-image \
				protobuf==2.5.0 \
				pyyaml==3.10 \
 		&& rm -rf /var/lib/apt/lists/*	\
    #start basic env
    \
    # prepare caffe start
    && wget https://github.com/google/glog/archive/v0.3.3.tar.gz \
 	  && tar zxvf v0.3.3.tar.gz \
 	  && cd glog-0.3.3 \
 	  && ./configure \
 	  && make && make install \
 	  \
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
  	&& git clone https://github.com/LMDB/lmdb && cd lmdb/libraries/liblmdb \
   	&& make && make install \
    && git clone https://github.com/BVLC/caffe.git && cd caffe \
    && git reset --hard d8f79537977f9dbcc2b7054a9e95be00eb6f26d0 \
    && cp Makefile.config.example Makefile.config \
    && sed -i 's/^# CPU_ONLY := 1$/CPU_ONLY := 1/' Makefile.config \
    && make all \
    && make test \
    && make runtest \
    && make distribute \
    && make pycaffe \
    && export CAFFE_DIR=/root/caffe \
    # end caffe build
    \
    # Android NDK
    && wget https://dl.google.com/android/repository/android-ndk-r11c-linux-x86_64.zip \
    && unzip android-ndk-r11c-linux-x86_64 \
    && export ANDROID_NDK_ROOT=/root/android-ndk-r11c-linux-x86_64 \
    # Android NDK
    \
    && cd /snpe \

CMD ["/bin/bash"]
