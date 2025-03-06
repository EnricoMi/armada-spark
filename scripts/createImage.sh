#!/bin/bash
set -e
source scripts/config.sh
source scripts/functions.sh

# generate armada docker image
#  run like so: scripts/createImage.sh /home/gbj/incoming/spark testing 2.13
SCALA_BIN_VERSION=`get_scala_bin_version $SPARK_HOME`
SPARK_VERSION=`get_spark_version $SPARK_HOME`

cp versions/v${SPARK_VERSION}/pom.xml pom.xml
cp versions/v${SPARK_VERSION}/SparkSubmit.scala src/main/scala/org/apache/spark/deploy/ArmadaSparkSubmit.scala

# Get the dependencies to be copied into docker image
mvn --batch-mode clean package dependency:copy-dependencies
dependencies=(
    target/armada-cluster-manager_${SCALA_BIN_VERSION}-1.0.0-SNAPSHOT.jar
    target/dependency/lenses_${SCALA_BIN_VERSION}-0.11.13.jar
    target/dependency/scalapb-runtime_${SCALA_BIN_VERSION}-0.11.13.jar
    target/dependency/scalapb-runtime-grpc_${SCALA_BIN_VERSION}-0.11.13.jar
    target/dependency/armada-scala-client_${SCALA_BIN_VERSION}-0.1.0-SNAPSHOT.jar

    # both
    target/dependency/grpc-api-1.47.1.jar
    target/dependency/grpc-core-1.47.1.jar
    target/dependency/grpc-netty-1.47.1.jar
    target/dependency/grpc-protobuf-1.47.1.jar
    target/dependency/grpc-context-1.47.1.jar
    target/dependency/grpc-stub-1.47.1.jar
    target/dependency/guava-31.0.1-android.jar
    target/dependency/failureaccess-1.0.1.jar
    target/dependency/perfmark-api-0.25.0.jar

    #3.3
    target/dependency/netty-codec-http2-4.1.72.Final.jar
    target/dependency/netty-codec-http-4.1.72.Final.jar
    target/dependency/protobuf-java-3.19.6.jar




)

if [ -e  $SPARK_HOME/assembly/target/scala-${SCALA_BIN_VERSION}/jars/guava-14.0.1.jar ]; then
    rm $SPARK_HOME/assembly/target/scala-${SCALA_BIN_VERSION}/jars/guava-14.0.1.jar
fi

if [ -e  $SPARK_HOME/assembly/target/scala-${SCALA_BIN_VERSION}/jars/protobuf-java-2.5.0.jar ]; then
    rm $SPARK_HOME/assembly/target/scala-${SCALA_BIN_VERSION}/jars/protobuf-java-2.5.0.jar
fi


# Copy dependencies to the docker image directory
cp "${dependencies[@]}" $SPARK_HOME/assembly/target/scala-${SCALA_BIN_VERSION}/jars/


# Make the image
cd $SPARK_HOME
#cp ./bin/docker-image-tool.sh /tmp
chmod 755 /tmp/docker-image-tool.sh
SPARK_HOME=$SPARK_HOME /tmp/docker-image-tool.sh -t $IMAGE_NAME build
