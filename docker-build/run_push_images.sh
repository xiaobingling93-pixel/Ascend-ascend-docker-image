version=24.0.RC1
public_repository=swr.cn-east-3.myhuaweicloud.com/test-ascendhub
private_repository=swr.cn-east-3.myhuaweicloud.com/ascendhub_ly
if [[ $2 == "public" ]]; then
    repository=${public_repository}
else
    repository=${private_repository}
fi
if [[ $(arch) == "x86_64" ]]; then
    ARCH=x64
else
    ARCH=arm64
fi

push_ascend_infer()
{
    docker tag ascend-infer:ubuntu20.04-${ARCH} ${repository}/ascend-infer:${version}-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-infer:${version}-ubuntu20.04-${ARCH}
    docker tag ascend-infer:openeuler20.03-${ARCH} ${repository}/ascend-infer:${version}-openeuler20.03-${ARCH}
    docker push ${repository}/ascend-infer:${version}-openeuler20.03-${ARCH}
}

push_ascend_infer_310b()
{
    docker tag ascend-infer-310b:${version}-arm64 ${repository}/ascend-infer-310b:${version}-arm64
    docker push ${repository}/ascend-infer-310b:${version}-arm64
    docker tag ascend-infer-310b:${version}-dev-arm64 ${repository}/ascend-infer-310b:${version}-dev-arm64
    docker push ${repository}/ascend-infer-310b:${version}-dev-arm64
}

push_ascend_toolkit()
{
    docker tag ascend-toolkit:A1-ubuntu20.04-${ARCH} ${repository}/ascend-toolkit:${version}-A1-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-toolkit:${version}-A1-ubuntu20.04-${ARCH}

    docker pull ${repository}/ascend-toolkit:${version}-A1-openeuler20.03-${ARCH}
    docker tag  ${repository}/ascend-toolkit:${version}-A1-openeuler20.03-${ARCH} ascend-toolkit:A1-openeuler20.03-${ARCH}
    docker tag ascend-toolkit:A2-ubuntu20.04-${ARCH} ${repository}/ascend-toolkit:${version}-A2-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-toolkit:${version}-A2-ubuntu20.04-${ARCH}
    docker pull ${repository}/ascend-toolkit:${version}-A2-openeuler20.03-${ARCH}
    docker tag  ${repository}/ascend-toolkit:${version}-A2-openeuler20.03-${ARCH} ascend-toolkit:A2-openeuler20.03-${ARCH}
}

push_ascend_toolkit_py310()
{
    docker tag ascend-toolkit:A1-ubuntu20.04-py310-${ARCH} ${repository}/ascend-toolkit:${version}-A1-ubuntu20.04-py310-${ARCH}
    docker push ${repository}/ascend-toolkit:${version}-A1-ubuntu20.04-py310-${ARCH}

    docker pull ${repository}/ascend-toolkit:${version}-A1-openeuler20.03-py310-${ARCH}
    docker tag   ${repository}/ascend-toolkit:${version}-A1-openeuler20.03-py310-${ARCH} ascend-toolkit:A1-openeuler20.03-py310-${ARCH}
    docker tag ascend-toolkit:A2-ubuntu20.04-py310-${ARCH} ${repository}/ascend-toolkit:${version}-A2-ubuntu20.04-py310-${ARCH}
    docker push ${repository}/ascend-toolkit:${version}-A2-ubuntu20.04-py310-${ARCH}

    docker push ${repository}/ascend-toolkit:${version}-A2-openeuler20.03-py310-${ARCH}
    docker tag  ${repository}/ascend-toolkit:${version}-A2-openeuler20.03-py310-${ARCH} ascend-toolkit:A2-openeuler20.03-py310-${ARCH}
}

push_ascend_mindspore()
{
    docker tag ascend-mindspore:A1-ubuntu20.04-${ARCH} ${repository}/ascend-mindspore:${version}-A1-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-mindspore:${version}-A1-ubuntu20.04-${ARCH}
    docker tag ascend-mindspore:A1-openeuler20.03-${ARCH} ${repository}/ascend-mindspore:${version}-A1-openeuler20.03-${ARCH}
    docker push ${repository}/ascend-mindspore:${version}-A1-openeuler20.03-${ARCH}
    docker tag ascend-mindspore:A2-ubuntu20.04-${ARCH} ${repository}/ascend-mindspore:${version}-A2-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-mindspore:${version}-A2-ubuntu20.04-${ARCH}
    docker tag ascend-mindspore:A2-openeuler20.03-${ARCH} ${repository}/ascend-mindspore:${version}-A2-openeuler20.03-${ARCH}
    docker push ${repository}/ascend-mindspore:${version}-A2-openeuler20.03-${ARCH}
}

push_ascend_pytorch1110()
{
    docker tag ascend-pytorch1.11.0:A1-ubuntu20.04-${ARCH} ${repository}/ascend-pytorch:${version}-A1-1.11.0-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-pytorch:${version}-A1-1.11.0-ubuntu20.04-${ARCH}
    docker tag ascend-pytorch1.11.0:A1-openeuler20.03-${ARCH} ${repository}/ascend-pytorch:${version}-A1-1.11.0-openeuler20.03-${ARCH}
    docker push ${repository}/ascend-pytorch:${version}-A1-1.11.0-openeuler20.03-${ARCH}
    docker tag ascend-pytorch1.11.0:A2-ubuntu20.04-${ARCH} ${repository}/ascend-pytorch:${version}-A2-1.11.0-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-pytorch:${version}-A2-1.11.0-ubuntu20.04-${ARCH}
    docker tag ascend-pytorch1.11.0:A2-openeuler20.03-${ARCH} ${repository}/ascend-pytorch:${version}-A2-1.11.0-openeuler20.03-${ARCH}
    docker push ${repository}/ascend-pytorch:${version}-A2-1.11.0-openeuler20.03-${ARCH}
}

push_ascend_pytorch210()
{
    docker tag ascend-pytorch2.1.0:A2-ubuntu20.04-${ARCH} ${repository}/ascend-pytorch:${version}-A2-2.1.0-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-pytorch:${version}-A2-2.1.0-ubuntu20.04-${ARCH}
}

push_ascend_tensorflow()
{
    docker tag ascend-tensorflow:A1-ubuntu20.04-${ARCH} ${repository}/ascend-tensorflow:${version}-A1-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-tensorflow:${version}-A1-ubuntu20.04-${ARCH}
    docker tag ascend-tensorflow:A1-openeuler20.03-${ARCH} ${repository}/ascend-tensorflow:${version}-A1-openeuler20.03-${ARCH}
    docker push ${repository}/ascend-tensorflow:${version}-A1-openeuler20.03-${ARCH}
    docker tag ascend-tensorflow:A2-ubuntu20.04-${ARCH} ${repository}/ascend-tensorflow:${version}-A2-ubuntu20.04-${ARCH}
    docker push ${repository}/ascend-tensorflow:${version}-A2-ubuntu20.04-${ARCH}
    docker tag ascend-tensorflow:A2-openeuler20.03-${ARCH} ${repository}/ascend-tensorflow:${version}-A2-openeuler20.03-${ARCH}
    docker push ${repository}/ascend-tensorflow:${version}-A2-openeuler20.03-${ARCH}
}

push_hccl_test()
{
    docker tag hccl-test:ubuntu20.04-${ARCH} ${repository}/hccl-test:${version}-ubuntu20.04-${ARCH}
    docker push ${repository}/hccl-test:${version}-ubuntu20.04-${ARCH}
}

push_testcases()
{
    docker tag testcases:ubuntu20.04-${ARCH} ${repository}/testcases:${version}-ubuntu20.04-${ARCH}
    docker push ${repository}/testcases:${version}-ubuntu20.04-${ARCH}
}

push_cluster()
{
    docker tag cluster-flops-test:ubuntu20.04-${ARCH} ${repository}/cluster-flops-test:${version}-ubuntu20.04-${ARCH}
    docker push ${repository}/cluster-flops-test:${version}-ubuntu20.04-${ARCH}
}


function parse_script_args()
{
    case "$1" in
    --help | -h)
        NEED_HELP=yes
        ;;
    --image-name=*)
        image=$(echo "$1" | cut -d"=" -f2)
        if [[ "${image}" = "infer" ]]; then
            push_ascend_infer
        elif [[ "${image}" = "mindspore" ]]; then
            push_ascend_mindspore
        elif [[ "${image}" = "pytorch1.11.0" ]]; then
            push_ascend_pytorch1110
        elif [[ "${image}" = "pytorch2.1.0" ]]; then
            push_ascend_pytorch210
        elif [[ "${image}" = "tensorflow" ]]; then
            push_ascend_tensorflow
        elif [[ "${image}" = "toolkit" ]]; then
            push_ascend_toolkit
        elif [[ "${image}" = "toolkit-py310" ]]; then
            push_ascend_toolkit_py310
        elif [[ "${image}" = "hccl-test" ]]; then
            push_hccl_test
        elif [[ "${image}" = "cluster" ]]; then
            push_cluster
        elif [[ "${image}" = "testcases" ]]; then
            push_testcases
        elif [[ "${image}" = "infer-310b" ]]; then
            push_ascend_infer_310b
        elif [[ "${image}" = "all" ]]; then
            push_ascend_infer
            push_ascend_toolkit_py310
            if [[ $(arch) = 'aarch64' ]];then
                push_ascend_infer_310b
            fi
            push_ascend_toolkit
            push_ascend_mindspore
            push_ascend_pytorch1110
            if [[ $(arch) = 'x86_64' ]];then
                push_ascend_pytorch210
            fi
            push_ascend_tensorflow
            push_hccl_test
            push_testcases
            push_cluster
        else
            echo "Please check the parameter of --image-name"
            exit 1
        fi
        ;;
    -*)
        echo "Unsupported parameters: $1"
        exit 1
        ;;
    *)
        if [ "$1" != "x" ]; then
            echo "Unsupported parameters: $1"
            exit 1
        fi
        break
        ;;
    esac
}

main()
{
    parse_script_args $@
    if [[ "${NEED_HELP}" = yes ]]; then
    cat <<EOF
run-push-images.sh is used to push images

Command: run-push-images.sh [OPTIONS]...

Options:
    -h, --help                    Displays the help information.

    --image-name=   toolkit       Specifies the common image to be created.
                    infer
                    infer-310b
                    toolkit-py310
                    mindspore
                    pytorch1.11.0
                    pytorch2.1.0
                    tensorflow
                    testcases
                    mindspore-modelzoo
                    hccl-test
                    cluster
                    all
EOF
        exit 0
    fi
}

main "$@"