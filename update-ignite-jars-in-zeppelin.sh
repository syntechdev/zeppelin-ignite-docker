#!/bin/bash

# [2018Aug09 MCK] script to download version of Ignite binaries, extract it into the local directory
#        create a directory, copy ignite jar files needed for Zeppelin into it, make a tarball,
#        and then build the Zeppelin Docker image which will copy these files

# The Apache Zeppelin docker image documented at: https://hub.docker.com/r/apache/zeppelin/~/dockerfile/
# It installs Apache Zeppelin using a recent binary from http://archive.apache.org/dist/zeppelin/ which
# contains jars for Ignite v2.3.0 - which will not work with more recent versions of Apache Ignite, at
# least in Apache Zepppelin v0.8.0

# This script will update the Apache Ignite jars found in this $ZEPPELIN_HOME/interpreter/ignite directory
# in the Docker image (where $ZEPPELIN_HOME is /zeppelin in the image).

# This /zeppelin/interpreter/ignite directory contains these files:
#
# annotations-13.0.jar       ignite-shmem-1.0.0.jar             META-INF                                 spring-beans-4.3.7.RELEASE.jar
# cache-api-1.0.0.jar        ignite-spring-2.3.0.jar            scala-compiler-2.11.8.jar                spring-context-4.3.7.RELEASE.jar
# commons-codec-1.5.jar      interpreter-setting.json           scala-library-2.11.8.jar                 spring-core-4.3.7.RELEASE.jar
# commons-logging-1.1.1.jar  log4j-1.2.17.jar                   scala-parser-combinators_2.11-1.0.4.jar  spring-expression-4.3.7.RELEASE.jar
# default-ignite-jdbc.xml    lucene-analyzers-common-5.5.2.jar  scala-reflect-2.11.8.jar                 spring-jdbc-4.3.7.RELEASE.jar
# h2-1.4.195.jar             lucene-core-5.5.2.jar              scala-xml_2.11-1.0.4.jar                 spring-tx-4.3.7.RELEASE.jar
# ignite-core-2.3.0.jar      lucene-queries-5.5.2.jar           slf4j-api-1.7.10.jar                     zeppelin-ignite_2.11-0.8.0.jar
# ignite-indexing-2.3.0.jar  lucene-queryparser-5.5.2.jar       slf4j-log4j12-1.7.10.jar
# ignite-scalar-2.3.0.jar    lucene-sandbox-5.5.2.jar           spring-aop-4.3.7.RELEASE.jar

# Make a directory for the files we need to update
mkdir -p interpreter/ignite
mkdir -p interpreter/jdbc

# The updated files can be found in the current Ignite binary distro here:
#   https://ignite.apache.org/download.cgi#binaries

# The latest version of the Ignite binaries is v2.6.0: apache-ignite-fabric-2.6.0-bin.zip
#   http://mirror.olnevhost.net/pub/apache//ignite/2.6.0/apache-ignite-fabric-2.6.0-bin.zip

IGNITE_VER=2.6.0
IGNITE_BIN_DISTRO=apache-ignite-fabric-${IGNITE_VER}-bin

#if not exist http://mirror.olnevhost.net/pub/apache//ignite/2.6.0/apache-ignite-fabric-2.6.0-bin.zip
    wget http://mirror.olnevhost.net/pub/apache//ignite/${IGNITE_VER}/${IGNITE_BIN_DISTRO}.zip
    unzip ${IGNITE_BIN_DISTRO}.zip
    pushd ${IGNITE_BIN_DISTRO}

# Most of these version issues should be handled by Maven during build if the pom.xml is updated -
#    but my attempts to compile and build Zeppelin encountered errors - may return to this later

# Once downloaded and untarred, the replacement Ignite binaries are located in the .../libs/
# sub-directory: apache-ignite-fabric-2.6.0-bin/libs/ and in the following sub-directories:
#    libs/ignite-indexing
#    libs/ignite-spring
#    libs/optional/ignite-log4j
#    libs/optional/ignite-scalar
#    libs/optional/ignite-slf4j
#    libs/optional/ignite-spark

# rm /zeppelin/interpreter/ignite/ignite*
cp -p libs/*.jar ../interpreter/ignite/

# Ignite-Indexing
# most of the ignite-indexing/ files are the same versions as already in the zeppelin/lib/ directory
#   except ignite-indexing-2.x.0.jar and commons-codec-1.5.jar which is replaced by commons-codec-1.11.jar
# rm /zeppelin/interpreter/ignite/commons-codec-1.5.jar
cp -p libs/ignite-indexing/*.jar ../interpreter/ignite/

# Ignite-Log4J
cp -p libs/optional/ignite-log4j/ignite*jar ../interpreter/ignite/

# Ignite-scalar
#   the ignite-scaler-2.6.0.jar is new but the scala-library-2.10.6.jar is the same in the zeppelin distro
cp -p libs/optional/ignite-scalar/ignite*jar ../interpreter/ignite/

# Ignite-slf4j
#   the ignite-slf4j-2.6.0.jar is new but the slf4j-api-1.7.7.jar is older than in the zeppelin distro
cp -p libs/optional/ignite-slf4j/ignite*jar ../interpreter/ignite/

# Ignite-Spring
# the spring jars in this release of zeppelin are all v4.3.7 so replacing since Ignite v2.6.0 includes spring v4.3.16
# rm /zeppelin/interpreter/ignite/spring*
 cp -p libs/ignite-spring/*jar ../interpreter/ignite/

# Ignite jdbc - for access to the Ignite-thin JDBC driver
# Following directions about putting the Ignite-core jar into the JDBC interpreter folder from here:
# https://apacheignite.readme.io/docs/genetic-algorithms#section-apache-zeppelin-integration
cp -p libs/ignite-core*jar ../interpreter/jdbc/

popd
 # Make a tarball that can be easily copied into the docker image
tar -cvzf update-interpreter-ignite.tgz interpreter/*
