#!/bin/bash
set -e

# generate armada spark docker image

root="$(cd "$(dirname "$0")/.."; pwd)"
scripts="$(cd "$(dirname "$0")"; pwd)"
source "$scripts/init.sh"

image_prefix=apache/spark
image_tag="$SPARK_VERSION-scala$SCALA_BIN_VERSION-java${JAVA_VERSION}-ubuntu"
if [[ "$SPARK_VERSION" == "3."* ]] && [[ "$SCALA_BIN_VERSION" == "2.13" ]]; then
  image_prefix=spark
  if ! docker image inspect "$image_prefix:$image_tag" >/dev/null 2>/dev/null; then
    echo "There are no Docker images released for Spark3 and Scala2.13."
    echo "A Docker image has to be built from Spark sources locally."
    if [[ ! -d ".spark-$SPARK_VERSION" ]]; then
      echo "Checking out Spark sources for tag v$SPARK_VERSION."
      git clone https://github.com/apache/spark --branch v$SPARK_VERSION --depth 1 --no-tags ".spark-$SPARK_VERSION"
    fi
    echo "Building Spark Docker image $image_prefix:$image_tag."
    cd ".spark-$SPARK_VERSION"
    ./dev/change-scala-version.sh 2.13
    ./build/mvn clean package -Pkubernetes -Pscala-2.13 -DskipTests -Dtest=none -Dmaven.test.skip=true
    ./bin/docker-image-tool.sh -t "$image_tag" build
    cd ..
  fi
fi

docker build \
  --tag $IMAGE_NAME \
  --build-arg spark_base_image_prefix=$image_prefix \
  --build-arg spark_base_image_tag=$image_tag \
  --build-arg scala_binary_version=$SCALA_BIN_VERSION \
  -f "$root/docker/Dockerfile" \
  "$root"
