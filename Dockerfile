FROM       apache/zeppelin:0.8.0
MAINTAINER Mohan Kartha <mckartha@gmail.com>
# Building on "official" apache/zeppelin Dockerfile here but updating Ignite binaries for Ignite v2.6.0
#     https://github.com/apache/zeppelin/blob/master/scripts/docker/zeppelin/bin/Dockerfile

ARG        DIST_MIRROR=http://archive.apache.org/dist/zeppelin
ARG        VERSION=0.8.0
ARG        IGNITE_VER=2.6.0
ENV        ZEPPELIN_HOME=/zeppelin
#
# This tar file is built by the update-ignite-jars-in-zeppelin.sh script which must be run before docker build
#   the script downloads Ignite version 2.6.0 and copies the new jar files to an interpreter/ directory structure
#   and makes a tarball to use to update the Zeppelin interpreter in the "official" image
RUN        rm -rf ${ZEPPELIN_HOME}/interpreter/ignite/ignite*.jar && \
           rm -rf ${ZEPPELIN_HOME}/interpreter/ignite/spring*.jar && \
           rm -rf ${ZEPPELIN_HOME}/interpreter/ignite/commons-codec-1.5.jar
ADD        update-interpreter-ignite.tgz ${ZEPPELIN_HOME}/
#
#VOLUME     ${ZEPPELIN_HOME}/logs \
#           ${ZEPPELIN_HOME}/notebook
WORKDIR    ${ZEPPELIN_HOME}

EXPOSE 8080 8443
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD ["bin/zeppelin.sh"]
