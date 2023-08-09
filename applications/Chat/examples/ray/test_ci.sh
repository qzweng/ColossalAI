#!/bin/bash
set -x
NUM_MAKERS=6
NUM_TRAINERS=2
TRAINER_STRATEGY="colossalai_zero2"
# TRAINER_STRATEGY="colossalai_gemini"

COATI_SCRIPT_VER="${NUM_MAKERS}m${NUM_TRAINERS}t-${TRAINER_STRATEGY}"
COATI_LOG_DIR="/nvme/ray/logs"
mkdir -p $COATI_LOG_DIR
export TZ='Asia/Shanghai'
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
    --num_makers $NUM_MAKERS \
    --num_trainers $NUM_TRAINERS \
    --trainer_strategy $TRAINER_STRATEGY \
    \
    --model opt \
    --pretrain facebook/opt-1.3b \
    --critic_model opt \
    --critic_pretrain facebook/opt-350m \
    \
    --experience_batch_size 4 \
    --experience_steps 10 \
    --train_batch_size 4 \
    --train_epoch 1 \
    --update_steps 1 \
    2>&1 | tee -a $COATI_LOG_FILE
    # --model opt \
    # --pretrain facebook/opt-125m \
    # --critic_model opt \
    # --critic_pretrain facebook/opt-125m \

    # --model bloom \
    # --pretrain "bigscience/bloom-560m" \
    # --critic_model bloom \
    # --critic_pretrain "bigscience/bloom-560m" \

    # --model bloom \
    # --pretrain "bigscience/bloom-7b1" \
    # --critic_model bloom \
    # --critic_pretrain "bigscience/bloom-7b1" \