DIR="$(cd "$(dirname "$0")" && pwd)"

# help message
if [ $# != 4 ]; then
  echo "Usage: bash scripts/run_distribute_train.sh [rank_size] [rank_start_id] [rank_table_file] [bert_ckpt]"
  exit 1
fi

ulimit -c unlimited
ulimit -n 65530
export SLOG_PRINT_TO_STDOUT=0
export RANK_SIZE=$1
export RANK_START_ID=$2
export RANK_TABLE_FILE=$3
export BERT_CKPT=$4

rm -rf $DIR/output_distribute
mkdir $DIR/output_distribute

for ((i = 0; i <= $RANK_SIZE - 1; i++)); do
  export RANK_ID=${i}
  export DEVICE_ID=$((i + RANK_START_ID))
  echo 'start rank='${i}', device id='${DEVICE_ID}'...'
  if [ -d $DIR/output_distribute/device${DEVICE_ID} ]; then
    rm -rf $DIR/output_distribute/device${DEVICE_ID}
  fi
  mkdir $DIR/output_distribute/device${DEVICE_ID}

  nohup python train.py \
    --device_id ${DEVICE_ID} --bert_ckpt ${BERT_CKPT} --rank_size ${RANK_SIZE} >$DIR/output_distribute/device${DEVICE_ID}_log.txt 2>&1 &
done
