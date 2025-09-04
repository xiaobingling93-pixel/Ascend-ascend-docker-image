#!/bin/bash

# bash build.sh to build linux/amd64 images
# bash build.sh aarch64 to build linux/arm64 images

set -e  # exit on error

IMAGE_NAME="ascend-npu-driver-installer"

ARCH="x86_64"
PLATFORM="linux/amd64"
BUILD_CMD="docker build"
if [ "$1" = "aarch64" ]; then
    ARCH="aarch64"
    PLATFORM="linux/arm64"
    BUILD_CMD="docker buildx build --platform ${PLATFORM}"
fi

ORIGIN_KO_ZIP="precompiled-ko-files-${ARCH}.zip"
KO_ZIP="precompiled-ko-files.zip"
UNZIPPED_DIR="precompiled-ko-files"

KO_ZIP_LINK="https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/images/npu-driver-installer/${ORIGIN_KO_ZIP}"
REFERER="https://www.hiascend.com/"

download_and_unzip_ko_files() {
    # check if file exists, if not, download it
    if [ ! -e "${KO_ZIP}" ]; then
        echo "download ${ORIGIN_KO_ZIP}..."
        # download with curl
        if curl -H "Referer: ${REFERER}" -o "${KO_ZIP}" "${KO_ZIP_LINK}"; then
            echo "download ${KO_ZIP} successfully"
        else
            echo "downlaod failed, please check network or link: ${KO_ZIP_LINK}"
            exit 1
        fi
    else
        echo "${KO_ZIP} exists, skip download"
    fi

    # unzip file
    echo "unzip ${KO_ZIP}..."
    if unzip -q "${KO_ZIP}" -d "${UNZIPPED_DIR}"; then
        echo "unzip ${KO_ZIP} successfully"
    else
        echo "unzip ${KO_ZIP} failed, please check if the file is valid"
        exit 1
    fi
}

build_docker_image() {
    # build docker images
    echo "start to build docker images[platform: ${PLATFORM}]..."
    ${BUILD_CMD} -f Dockerfile_openeuler22.03 -t "${IMAGE_NAME}":openeuler-22.03 . 
    ${BUILD_CMD} -f Dockerfile_openeuler24.03 -t "${IMAGE_NAME}":openeuler-24.03 . 
    ${BUILD_CMD} -f Dockerfile_ubuntu20.04 -t "${IMAGE_NAME}":ubuntu-20.04 . 
}

clear_temp_files() {
    # remove the tmp files
    echo "clear tmp files..."
    rm -rf "${KO_ZIP}"
    rm -rf "${UNZIPPED_DIR}"
}

main() {
    local platform_arg="$1"
    download_and_unzip_ko_files
    build_docker_image
    clear_temp_files
    echo "build docker images successfully."
}

main "$@"