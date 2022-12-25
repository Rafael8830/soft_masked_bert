if [[ $# -lt 3 || $# -gt 4 ]]; then
    echo "Usage: bash scripts/run_infer_310.sh [MINDIR_PATH] [DATA_FILE_PATH] [NEED_PREPROCESS] [DEVICE_ID]
    MINDIR_PATH is necessary which means the directory of the model file.
    DATA_FILE_PATH is necessary which means the directory of the input data.
    NEED_PREPROCESS is necessary which means weather need preprocess or not, it's value is 'y' or 'n'.
    DEVICE_ID is optional, it can be set by environment variable device_id, otherwise the value is zero.
    Example: bash scripts/run_infer_310.sh ./checkpoint/smb.mindir ./dataset/dev_json y 0"
exit 1
fi

get_real_path(){
    if [ "${1:0:1}" == "/" ]; then
        echo "$1"
    else
        echo "$(realpath -m $PWD/$1)"
    fi
}
model=$(get_real_path $1)
eval_data_file_path=$(get_real_path $2)

if [ "$3" == "y" ] || [ "$3" == "n" ];then
    need_preprocess=$3
else
  echo "weather need preprocess or not, it's value must be in [y, n]"
  exit 1
fi

device_id=0
if [ $# == 4 ]; then
    device_id=$4
fi


echo "mindir path: "$model
echo "eval_data_file_path: "$eval_data_file_path
echo "need preprocess: "$need_preprocess
echo "device id: "$device_id


export ASCEND_HOME=/usr/local/Ascend/
if [ -d ${ASCEND_HOME}/ascend-toolkit ]; then
    export PATH=$ASCEND_HOME/fwkacllib/bin:$ASCEND_HOME/fwkacllib/ccec_compiler/bin:$ASCEND_HOME/ascend-toolkit/latest/fwkacllib/ccec_compiler/bin:$ASCEND_HOME/ascend-toolkit/latest/atc/bin:$PATH
    export LD_LIBRARY_PATH=$ASCEND_HOME/fwkacllib/lib64:/usr/local/lib:$ASCEND_HOME/ascend-toolkit/latest/atc/lib64:$ASCEND_HOME/ascend-toolkit/latest/fwkacllib/lib64:$ASCEND_HOME/driver/lib64:$ASCEND_HOME/add-ons:$LD_LIBRARY_PATH
    export TBE_IMPL_PATH=$ASCEND_HOME/ascend-toolkit/latest/opp/op_impl/built-in/ai_core/tbe
    export PYTHONPATH=$ASCEND_HOME/fwkacllib/python/site-packages:${TBE_IMPL_PATH}:$ASCEND_HOME/ascend-toolkit/latest/fwkacllib/python/site-packages:$PYTHONPATH
    export ASCEND_OPP_PATH=$ASCEND_HOME/ascend-toolkit/latest/opp
else
    export ASCEND_HOME=/usr/local/Ascend/latest/
    export PATH=$ASCEND_HOME/fwkacllib/bin:$ASCEND_HOME/fwkacllib/ccec_compiler/bin:$ASCEND_HOME/atc/ccec_compiler/bin:$ASCEND_HOME/atc/bin:$PATH
    export LD_LIBRARY_PATH=$ASCEND_HOME/fwkacllib/lib64:/usr/local/lib:$ASCEND_HOME/atc/lib64:$ASCEND_HOME/acllib/lib64:$ASCEND_HOME/driver/lib64:$ASCEND_HOME/add-ons:$LD_LIBRARY_PATH
    export PYTHONPATH=$ASCEND_HOME/fwkacllib/python/site-packages:$ASCEND_HOME/atc/python/site-packages:$PYTHONPATH
    export ASCEND_OPP_PATH=$ASCEND_HOME/opp
fi

function preprocess_data()
{
    if [ -d preprocess_result ]; then
        rm -rf ./preprocess_result
    fi
    mkdir preprocess_result
    python preprocess.py --eval_data_file_path=$eval_data_file_path  --result_path=./preprocess_result/
}

function compile_app()
{
    cd ./ascend310_infer || exit
    if [ -f "Makefile" ]; then
      make clean
    fi
    bash build.sh &> build.log
}

function infer()
{
    cd .. || exit
    if [ -d result_files ]; then
        rm -rf ./result_files
    fi
    if [ -d time_result ]; then
        rm -rf ./time_result
    fi
    mkdir result_files
    mkdir time_result
    mkdir ./result_files/result_00
    mkdir ./result_files/result_01
    mkdir ./result_files/result_02
    mkdir ./result_files/result_03
    mkdir ./result_files/result_04
    mkdir ./result_files/result_05

    ./ascend310_infer/softmaskedbert --mindir_path=$model --input0_path=./preprocess_result/00_data --input1_path=./preprocess_result/01_data --input2_path=./preprocess_result/02_data --input3_path=./preprocess_result/03_data --input4_path=./preprocess_result/04_data --input5_path=./preprocess_result/05_data --input6_path=./preprocess_result/06_data --device_id=$device_id &> infer.log

}

function cal_acc()
{
    python ./postprocess.py --result_dir_00=./result_files/result_00 --result_dir_01=./result_files/result_01 --result_dir_02=./result_files/result_02 --result_dir_03=./result_files/result_03 --result_dir_04=./result_files/result_04 --result_dir_05=./result_files/result_05 &> acc.log

}

if [ $need_preprocess == "y" ]; then
    preprocess_data
    if [ $? -ne 0 ]; then
        echo "preprocess dataset failed"
        exit 1
    fi
fi
compile_app
if [ $? -ne 0 ]; then
    echo "compile app code failed"
    exit 1
fi
infer
if [ $? -ne 0 ]; then
    echo " execute inference failed"
    exit 1
fi
cal_acc
if [ $? -ne 0 ]; then
    echo "calculate accuracy failed"
    exit 1
fi
