if [ $# != 3 ]
then
    echo "Usage: bash scripts/run_standalone_train.sh [BERT_CKPT] [DEVICE_ID] [PYNATIVE]"
exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

rm -rf $DIR/output_standalone
mkdir $DIR/output_standalone

nohup python train.py --bert_ckpt $1 --device_id $2 --pynative $3 >>$DIR/output_standalone/device_log.txt 2>&1 &
