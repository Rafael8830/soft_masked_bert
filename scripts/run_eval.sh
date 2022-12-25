DIR="$(cd "$(dirname "$0")" && pwd)"

# help message
if [ $# != 2 ]; then
  echo "Usage: bash scripts/run_eval.sh [bert_ckpt] [ckpt_dir]"
  exit 1
fi

rm -rf $DIR/output_eval
mkdir $DIR/output_eval

export BERT_CKPT=$1
export CKPT_DIR=$2

nohup python eval.py --bert_ckpt ${BERT_CKPT} --ckpt_dir ${CKPT_DIR}  >$DIR/output_eval/eval_log.txt 2>&1 &
