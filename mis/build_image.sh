#!/bin/bash

workdir=$(
  cd $(dirname $0) || exit
  pwd
)

default_llm_cann=mis-llm-cann:0.1
default_vlm_cann=mis-vlm-cann:0.1
default_llm_base=mis-llm-base:0.1
default_vlm_base=mis-vlm-base:0.1
default_llm_model=DeepSeek-R1-Distill-Qwen-7B
default_vlm_model=Qwen2.5-VL-7B-Instruct
default_version=0.1


function build_llm_cann_image() {
  llm_cann_image=$2

  if [ -z "${llm_cann_image}" ]; then
    llm_cann_image=${default_llm_cann}
  fi

  echo "build llm cann image with name [${llm_cann_image}]"

  if docker images --format "{{.Repository}}{{.Tag}}" | grep -q "^${llm_cann_image}&"; then
    echo "building llm cann image: ${llm_cann_image} exist"
  else
    echo "building llm cann image: ${llm_cann_image}"
    cd "$workdir"/dockerfiles/cann || exit
    docker build -t ${llm_cann_image} -f Dockerfile_llm . || exit
  fi
}

function build_vlm_cann_image() {
  vlm_cann_image=$2

  if [ -z "${vlm_cann_image}" ]; then
    vlm_cann_image=$default_vlm_base
  fi

  echo "build vlm cann image with name [${vlm_cann_image}]"

  if docker images --format "{{.Repository}}{{.Tag}}" | grep -q "^${vlm_cann_image}&"; then
    echo "building vlm cann image: ${vlm_cann_image} exist"
  else
    echo "building vlm cann image: ${vlm_cann_image}"
    cd "$workdir"/dockerfiles/cann || exit
    docker build -t ${vlm_cann_image} -f Dockerfile_vlm . || exit
  fi
}

function build_llm_base_image() {
  llm_cann_image=$2
  if [ -z "${llm_cann_image}" ]; then
    llm_cann_image=${default_llm_cann}
  fi

  llm_base_image=$3
  if [ -z "${llm_base_image}" ]; then
    llm_base_image=$default_llm_base
  fi

  echo "from [${llm_cann_image}] build llm-base image with name [${llm_base_image}]"

  if docker images --format "{{.Repository}}{{.Tag}}" | grep -q "^${llm_base_image}&"; then
    echo "building llm-base image: ${llm_base_image} exist"
  else
    echo "building llm-base image: ${llm_base_image}"
    cd "$workdir"/dockerfiles/llm/base || exit
    docker build --build-arg BASE_IMAGE=${llm_cann_image} -t ${llm_base_image} . || exit
  fi
}

function build_vlm_base_image() {
  vlm_cann_image=$2
  if [ -z "${vlm_cann_image}" ]; then
    vlm_cann_image=${default_vlm_cann}
  fi

  vlm_base_image=$3
  if [ -z "${vlm_base_image}" ]; then
    vlm_base_image=${default_vlm_base}
  fi

  echo "from [${vlm_cann_image}] build llm-base image with name [${vlm_base_image}]"

  if docker images --format "{{.Repository}}{{.Tag}}" | grep -q "^${vlm_base_image}&"; then
    echo "building vlm-base image: ${vlm_base_image} exist"
  else
    echo "building vlm-base image: ${vlm_base_image}"
    cd "$workdir"/dockerfiles/vlm/base || exit
    docker build --build-arg BASE_IMAGE=${vlm_cann_image} -t ${vlm_base_image} . || exit
  fi
}

function build_llm_model_image() {
  llm_base_image=$2
  model_name=$3
  version=$4

  if [ -z "${llm_base_image}" ]; then
    llm_base_image=${default_llm_base}
  fi

  if [ -z "$model_name" ]; then
    model_name=${default_llm_model}
  fi

  if [ -z "$version" ]; then
    version=${default_version}
  fi

  typeset -l model_name_lower
  model_name_lower=$model_name

  echo "from [${llm_base_image}] build llm model image with name [$model_name_lower:$version]"

  cd $workdir || exit
  docker_build_dir=$workdir/dockerfiles/llm/model/build
  mkdir -p "$docker_build_dir"
  rm -rf "$docker_build_dir"/*

  cp -r "$workdir"/llm/mis*.whl "$docker_build_dir"
  cp -r "$workdir"/patch "$docker_build_dir"

  mkdir -p "$docker_build_dir"/configs/llm/$model_name_lower
  cp -r "$workdir"/configs/llm/$model_name_lower/* "$docker_build_dir"/configs/llm/$model_name_lower

  cd $workdir/dockerfiles/llm/model || exit

  docker build --build-arg BASE_IMAGE=${llm_base_image} --build-arg MODEL="$model_name" -t "$model_name_lower":"$version" . || exit
}

function build_vlm_model_image() {
  vlm_base_image=$2
  model_name=$3
  version=$4

  if [ -z "${vlm_base_image}" ]; then
    vlm_base_image=${default_vlm_base}
  fi

  if [ -z "$model_name" ]; then
    model_name=${default_vlm_model}
  fi

  if [ -z "$version" ]; then
    version=${default_version}
  fi

  typeset -l model_name_lower
  model_name_lower=$model_name

  echo "from [${vlm_base_image}] build vlm model image with name [$model_name_lower:$version]"

  cd $workdir || exit
  docker_build_dir=$workdir/dockerfiles/vlm/model/build
  mkdir -p "$docker_build_dir"
  rm -rf "$docker_build_dir"/*

  cp -r "$workdir"/vlm/mis*.whl "$docker_build_dir"

  mkdir -p "$docker_build_dir"/configs/llm/$model_name_lower
  cp -r "$workdir"/configs/llm/$model_name_lower/* "$docker_build_dir"/configs/llm/$model_name_lower

  cd $workdir/dockerfiles/vlm/model || exit

  docker build --build-arg BASE_IMAGE=${vlm_base_image} --build-arg MODEL="$model_name" -t "$model_name_lower":"$version" . || exit
}

stage=$1
case $stage in
  "llm-cann")
    build_llm_cann_image "$1" "$2"
    ;;
  "llm-base")
    build_llm_base_image "$1" "$2" "$3"
    ;;
  "llm-model")
    build_llm_model_image "$1" "$2" "$3" "$4"
    ;;
  "vlm-cann")
    build_vlm_cann_image "$1" "$2"
    ;;
  "vlm-base")
    build_vlm_base_image "$1" "$2" "$3"
    ;;
  "vlm-model")
    build_vlm_model_image "$1" "$2" "$3" "$4"
    ;;
  *) echo "Invalid stage, we only support [llm-cann, llm-base, llm-model, vlm-cann, vlm-base, vlm-model]"
esac
