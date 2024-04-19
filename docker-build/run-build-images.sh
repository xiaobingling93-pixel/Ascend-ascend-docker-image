## 生成镜像
function build_image()
{
    cd ../$1
    bash build.sh
    cd -
}

function parse_script_args()
{
    while true; do
        case "$1" in
        --help | -h)
            NEED_HELP=yes
            shift
            ;;
        --modelzoo=*)
            image=$(echo "$1" | cut -d"=" -f2)
            if [[ "${image}" = "mindspore" ]]; then
                build_image mindspore-modelzoo
            else
                echo "Please check the parameter of --modelzoo"
                exit 1
            fi
            shift
            ;;
        --common=*)
            image=$(echo "$1" | cut -d"=" -f2)
            arch=$(arch)
            if [[ "${image}" = "infer" ]]; then
                build_image ascend-infer
            elif [[ "${image}" = "mindspore" ]]; then
                build_image ascend-mindspore
            elif [[ "${image}" = "pytorch1.11.0" ]]; then
                build_image ascend-pytorch1.11.0
            elif [[ "${image}" = "pytorch2.1.0" ]]; then
                build_image ascend-pytorch2.1.0
            elif [[ "${image}" = "tensorflow" ]]; then
                build_image ascend-tensorflow
            elif [[ "${image}" = "toolkit" ]]; then
                build_image ascend-toolkit
            elif [[ "${image}" = "base-infer" ]]; then
                build_image ascendbase-infer
            elif [[ "${image}" = "base-toolkit" ]]; then
                build_image ascendbase-toolkit
            elif [[ "${image}" = "hccl-test" ]]; then
                build_image hccl-test
            elif [[ "${image}" = "testcases" ]]; then
                build_image testcases
            elif [[ "${image}" = "cluster" ]]; then
                build_image cluster-flops-test
            elif [[ "${image}" = "infer-310b" ]]; then
              if [[ "${arch}" = "aarch64" ]]; then
                build_image ascend-infer-310b
              fi
            elif [[ "${image}" = "all" ]]; then
                build_image ascendbase-toolkit
                build_image ascendbase-infer
                build_image ascend-infer
                if [[ "${arch}" = "aarch64" ]]; then
                  build_image ascend-infer-310b
                fi
                build_image ascend-toolkit
                build_image ascend-mindspore
                build_image ascend-pytorch1.11.0
                build_image ascend-pytorch2.1.0
                build_image ascend-tensorflow
                build_image hccl-test
                build_image cluster-flops-test
            else
                echo "Please check the parameter of --common"
                exit 1
            fi
            shift
            ;;
        -*)
            echo "Unsupported parameters: $1"
            exit 1
            ;;
        *)
            if [ "x$1" != "x" ]; then
                echo "Unsupported parameters: $1"
                exit 1
            fi
            break
            ;;
        esac
    done
}

main()
{
    parse_script_args $@
    if [[ "${NEED_HELP}" = yes ]]; then
    cat <<EOF
run-build-images.sh is used to build images

Command: run-build-images.sh [OPTIONS]...

Options:
    -h, --help                    Displays the help information.
    --modelzoo= mindspore         Specifies the modelzoo image to be created.

    --common=   base-infer        Specifies the common image to be created.
                base-toolkit
                toolkit
                infer
                infer-310b
                mindspore
                pytorch1.11.0
                pytorch2.1.0
                tensorflow
                hccl-test
                cluster
                all
EOF
        exit 0
    fi
}

main "$@"