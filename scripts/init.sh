#!/bin/bash

# Utility functions

if [ -e "scripts/config.sh" ]; then
    source scripts/config.sh
fi

print_usage () {
    echo ' Usage:'
    echo '   -h  help'
    echo '   -s  <spark-home>'
    echo '   -i  <image-name>'
    echo '   -m  <armada-master-url>'
    echo '   -q  <armada-queue>'
    echo ''
    echo 'You also can specify those parameters in scripts/config.sh, like so:'
    echo '   SPARK_HOME=../spark'
    echo '   IMAGE_NAME=testing'
    echo '   ARMADA_MASTER=armada://localhost:30002'
    echo '   ARMADA_QUEUE=test'
    exit 1
}

while getopts "hs:i:m:q" opt; do
  case "$opt" in
    h) print_usage ;;
    s) SPARK_HOME=$OPTARG ;;
    i) IMAGE_NAME=$OPTARG ;;
    m) ARMADA_MASTER=$OPTARG ;;
    q) ARMADA_QUEUE=$OPTARG ;;
  esac
done

get_scala_bin_version () {
    grep '<scala.binary.version>' $SPARK_HOME/pom.xml | head -1  | grep -oP '(?<=<scala.binary.version>).*?(?=</scala.binary.version>)'
}

get_spark_version () {
    grep -A1 spark-parent $SPARK_HOME/pom.xml | tail -1   | grep -oP '(?<=<version>).*?(?=</version>)'
}

SCALA_BIN_VERSION=`get_scala_bin_version`
SPARK_VERSION=`get_spark_version`

if ! [ -e versions/$SPARK_VERSION ]; then
    echo This tool does not support Spark version $SPARK_VERSION . Exiting
    exit 1
fi