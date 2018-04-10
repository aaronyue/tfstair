FROM centos:6.6

COPY CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
COPY epel-6.repo /etc/yum.repos.d/epel.repo
COPY tair.zip /
COPY docker-entrypoint.sh /
ADD conf.tar.gz / 


ENV TBLIB_ROOT=/usr/local TZ=Asia/Shanghai

RUN echo $TZ > /etc/timezone && yum clean all && \
    yum -y install unzip gperftools-devel.x86_64 jemalloc-devel.x86_64 gcc.x86_64 gcc-c++.x86_64 make.x86_64 automake.noarch libtool.x86_64 readline-devel.x86_64 libuuid-devel zlib-devel mysql-devel wget tar subversion.x86_64 && \
    mkdir /tmp/taobao && cd /tmp/taobao && \
    svn checkout -r 18 http://code.taobao.org/svn/tb-common-utils/trunk/ tb-common-utils && \
    sh tb-common-utils/build.sh && \
    rm -rf tb-common-utils && \
    svn co http://code.taobao.org/svn/tfs/tags/release-2.2.16 && cd release-2.2.16 && \
    sed -i '1i #include <stdint.h>' ./src/common/session_util.h && \
    sed -i '1584c char* pos = (char *) strstr(sub_dir, parents_dir);' ./src/name_meta_server/meta_server_service.cpp && \
    ./build.sh init && ./configure --prefix=/usr/local/tfs --with-release=yes && make && make install && \
    cd /tmp/taobao && rm -rf release-2.2.16 && rm -rf /tmp/jemalloc-* && \
    mv /tair.zip . && unzip tair.zip && \
    rm -rf tair.zip && cd /tmp/taobao/tair-master && \
    sh bootstrap.sh && ./configure --prefix=/usr/local/tair --with-release=yes && make && make install && cd / &&rm -rf /tmp/taobao && \
    yum remove -y unzip gcc gcc-c++ wget tar subversion perl mysql && \
    rm -rf /usr/local/tair/etc/*.default && sed -i 's/grep tmpfs/grep \/dev\/shm/g' /usr/local/tair/tair.sh && \
    mv /tfsconf/* /usr/local/tfs/conf/ && mv /tairconf/* /usr/local/tair/etc/


WORKDIR /usr/local
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 5198 8108