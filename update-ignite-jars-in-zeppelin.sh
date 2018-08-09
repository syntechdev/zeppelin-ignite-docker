#!/bin/bash

# [2018Aug09 MCK] script to download version of Ignite binaries, extract it into the local directory
#        create a directory, copy ignite jar files needed for Zeppelin into it, make a tarball,
#        and then build the Zeppelin Docker image which will copy these files

# The Zeppelin docker image documented at: https://hub.docker.com/r/apache/zeppelin/~/dockerfile/
# installs Zeppelin using a recent binary from http://archive.apache.org/dist/zeppelin/ which
# contains jars for Ignite v2.3.0 - which will not work with more recent versions of ignite

# This script will update the Ignite jars found in this $ZEPPELIN_HOME/interpreter/ignite directory
# in the Docker image (where $ZEPPELIN_HOME is /zeppelin in the image).

# This /zeppelin/interpreter/ignite directory contains these files:
#
#
