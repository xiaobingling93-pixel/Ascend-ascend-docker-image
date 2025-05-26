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

function build_tei_cann_image() {
  cann_image=$2
  platform=$3
  python_version=$4
  if [ -z "$cann_image" ]; then
    cann_image="mis-cann:0.1"
  fi

  if [ -z "$platform" ]; then
    platform="910B"
  fi

  if [ -z "$python_version" ]; then
    python_version="3.10"
  fi

  echo "build cann image with name [$cann_image]"

  if docker images --format "{{.Repository}}{{.Tag}}" | grep -q "^${cann_image}&"; then
    echo "cann image: ${cann_image} exist"
  else
    echo "building cann image: ${cann_image}"
    cd "$workdir"/dockerfiles/cann || exit
    docker build --build-arg http_proxy=$HTTP_PROXY --build-arg https_proxy=$HTTP_PROXY --build-arg PYTHON_VER=${python_version} -t $cann_image . || exit
  fi
}

function build_clip_cann_image() {
  cann_image=$2
  platform=$3
  python_version=$4
  if [ -z "$cann_image" ]; then
    cann_image="mis-cann:0.1"
  fi

  if [ -z "$platform" ]; then
    platform="910B"
  fi

  if [ -z "$python_version" ]; then
    python_version="3.10"
  fi

  echo "build cann image with name [$cann_image]"

  if docker images --format "{{.Repository}}{{.Tag}}" | grep -q "^${cann_image}&"; then
    echo "cann image: ${cann_image} exist"
  else
    echo "building cann image: ${cann_image}"
    cd "$workdir"/dockerfiles/cann || exit
    docker build --build-arg http_proxy=$HTTP_PROXY --build-arg https_proxy=$HTTP_PROXY --build-arg PYTHON_VER=${python_version} -t $cann_image . || exit
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


function build_tei_base_image() {
  cann_image=$2
  tei_base_image=$3
  platform=$4

  if [ -z "$cann_image" ]; then
    cann_image="mis-cann:0.1"
  fi

  if [ -z "$tei_base_image" ]; then
    tei_base_image="mis-tei-base:0.1"
  fi

  if [ -z "$platform" ]; then
    platform="910B"
  fi

  echo "from [$cann_image] build tei-base image with name [$tei_base_image]"

  cd $workdir || exit
  docker_build_dir=$workdir/dockerfiles/emb/tei/base/build
  mkdir -p $docker_build_dir
  cp -r $workdir/patch/tei.patch $docker_build_dir
  cd $workdir/dockerfiles/emb/tei/base || exit

  if docker images --format "{{.Repository}}{{.Tag}}" | grep -q "^${tei_base_image}&"; then
    echo "tei-base image: ${tei_base_image} exist"
  else
    echo "building tei-base image: ${tei_base_image}"
    cd "$workdir"/dockerfiles/emb/tei/base || exit
    docker build --build-arg http_proxy=$HTTP_PROXY --build-arg https_proxy=$HTTP_PROXY --build-arg BASE_IMAGE=$cann_image --build-arg ARCH=$(uname -m) --build-arg PLATFORM=${platform} -t $tei_base_image . || exit
  fi
}

function build_clip_base_image() {
  cann_image=$2
  clip_base_image=$3
  platform=$4

  if [ -z "$cann_image" ]; then
    cann_image="mis-cann:0.1"
  fi

  if [ -z "$clip_base_image" ]; then
    clip_base_image="mis-clip-base:0.1"
  fi

  if [ -z "$platform" ]; then
    platform="910B"
  fi

  echo "from [$cann_image] build clip-base image with name [$clip_base_image]"

  cd $workdir || exit
  docker_build_dir=$workdir/dockerfiles/emb/clip/base/build
  mkdir -p $docker_build_dir
  cp -r $workdir/patch/clip.patch $docker_build_dir
  cd $workdir/dockerfiles/emb/clip/base || exit

  if docker images --format "{{.Repository}}{{.Tag}}" | grep -q "^${clip_base_image}&"; then
    echo "clip-base image: ${clip_base_image} exist"
  else
    echo "building clip-base image: ${clip_base_image}"
    cd "$workdir"/dockerfiles/emb/clip/base || exit
    docker build --build-arg http_proxy=$HTTP_PROXY --build-arg https_proxy=$HTTP_PROXY --build-arg BASE_IMAGE=$cann_image --build-arg ARCH=$(uname -m) --build-arg PLATFORM=${platform} -t $clip_base_image . || exit
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

function build_tei_model_image() {
  tei_base_image=$2
  model_name=$3
  version=$4

  if [ -z "$tei_base_image" ]; then
    tei_base_image="mis-tei-base:0.1"
  fi

  if [ -z "$model_name" ]; then
    model_name="bge-large-zh-v1.5"
  fi

  if [ -z "$version" ]; then
    version="0.1"
  fi

  typeset -l model_name_lower
  model_name_lower=$model_name

  echo "from [$tei_base_image] build model image with name [$model_name_lower:$version]"

  cd $workdir || exit
  docker_build_dir=$workdir/dockerfiles/emb/tei/model/build
  mkdir -p "$docker_build_dir"

  if [[ ! -e $workdir/configs/emb/tei/$model_name/config.json ]]; then
      echo "$workdir/configs/emb/tei/$model_name/config.json not exist, build image failed"
      exit 1
  fi

  cp -r $workdir/configs/emb/tei/${model_name}/config.json $docker_build_dir

  cd $workdir/dockerfiles/emb/tei/model || exit

  sed -i "s|export MIS_MODEL=.*|export MIS_MODEL=MindSDK/${model_name}|g" $workdir/dockerfiles/emb/tei/model/start_tei.sh

  docker build --no-cache  --build-arg http_proxy=$HTTP_PROXY --build-arg https_proxy=$HTTP_PROXY --build-arg BASE_IMAGE=$tei_base_image --build-arg MODEL="$model_name" -t "$model_name_lower":"$version" . || exit
}

function build_clip_model_image() {
  clip_base_image=$2
  model_name=$3
  version=$4

  if [ -z "$clip_base_image" ]; then
    clip_base_image="mis-clip-base:0.1"
  fi

  if [ -z "$model_name" ]; then
    model_name="ViT-B-16"
  fi

  if [ -z "$version" ]; then
    version="0.1"
  fi

  typeset -l model_name_lower
  model_name_lower=$model_name

  echo "from [$clip_base_image] build model image with name [$model_name_lower:$version]"

  cd $workdir || exit
  docker_build_dir=$workdir/dockerfiles/emb/clip/model/build
  mkdir -p "$docker_build_dir"

  if [[ ! -e $workdir/configs/emb/clip/$model_name/config.yaml ]]; then
      echo "$workdir/configs/emb/clip/$model_name/config.yaml not exist, build image failed"
      exit 1
  fi

  cp -r $workdir/configs/emb/clip/${model_name}/config.yaml $docker_build_dir

  cd $workdir/dockerfiles/emb/clip/model || exit
  sed -i "s|export MIS_MODEL=.*|export MIS_MODEL=MindSDK/${model_name}|g" $workdir/dockerfiles/emb/tei/model/start_clip.sh

  docker build --no-cache --build-arg http_proxy=$HTTP_PROXY --build-arg https_proxy=$HTTP_PROXY --build-arg BASE_IMAGE=$clip_base_image --build-arg MODEL="$model_name" -t "$model_name_lower":"$version" . || exit
}


stage=$1
case $stage in
  "llm-cann")
    build_llm_cann_image  "$@"
    ;;
  "llm-base")
    build_llm_base_image  "$@"
    ;;
  "llm-model")
    build_llm_model_image  "$@"
    ;;
  "vlm-cann")
    build_vlm_cann_image  "$@"
    ;;
  "vlm-base")
    build_vlm_base_image  "$@"
    ;;
  "vlm -model")
    build_vlm_model_image  "$@"
    ;;
  "tei-cann")
    build_tei_cann_image  "$@"
    ;;
  "tei-base")
    build_tei_base_image "$@"
    ;;
  "tei-model")
    build_tei_model_image "$@"
    ;;

  "clip-cann")
    build_clip_cann_image  "$@"
    ;;
  "clip-base")
    build_clip_base_image "$@"
    ;;
  "clip-model")
    build_clip_model_image "$@"
    ;;
  *) echo "Invalid stage, we only support [llm-cann, llm-base, llm-model; vlm-cann, vlm-base, vlm-model;tei-cann, tei-base, tei-model;clip-cann, clip-base, clip-model]"
esac