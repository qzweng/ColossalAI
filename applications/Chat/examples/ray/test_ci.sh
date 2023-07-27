#!/bin/bash
set -x
COATI_SCRIPT_VER="1m2t"
COATI_LOG_DIR="/nvme/ray/logs"
mkdir -p $COATI_LOG_DIR
DATE=$(date +%Y%m%d-%H:%M:%S)
COATI_LOG_FILE="${COATI_LOG_DIR}/${DATE}-${COATI_SCRIPT_VER}.log"
touch $COATI_LOG_FILE

BASE=$(realpath $(dirname $0))
export RAY_NAMESPACE=admin
export DATA=${BASE}/prompts.csv # https://huggingface.co/datasets/fka/awesome-chatgpt-prompts/resolve/main/prompts.csv

# install requirements
pip install -q -r ${BASE}/requirements.txt       # applications/Chat/examples/ray/
pip install -q -r ${BASE}/../../requirements.txt # applications/Chat/

python ${BASE}/mmmt_prompt.py \
    --prompt_path $DATA \
    --num_makers 2 \
    --num_trainers 2 \
    --trainer_strategy colossalai_gemini \
    --model opt \
    --critic_model opt \
    --pretrain facebook/opt-125m \
    --critic_pretrain facebook/opt-125m \
    --experience_batch_size 4 \
    --train_batch_size 4 \
    --train_epoch 100 \
    --debug \
    2>&1 | tee -a $COATI_LOG_FILE
