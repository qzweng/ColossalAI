#!/bin/bash
set -x
NUM_GPUS=8
TRAINER_STRATEGY="colossalai_zero2"
# TRAINER_STRATEGY="colossalai_gemini"
# "ddp" "naive"

COATI_SCRIPT_VER="${NUM_GPUs}g-${TRAINER_STRATEGY}"
COATI_LOG_DIR="/nvme/coati/logs"
mkdir -p $COATI_LOG_DIR
export TZ='Asia/Shanghai'
DATE=$(date +%Y%m%d-%H:%M:%S)
COATI_LOG_FILE="${COATI_LOG_DIR}/${DATE}-${COATI_SCRIPT_VER}.log"
touch $COATI_LOG_FILE

set_n_least_used_CUDA_VISIBLE_DEVICES() {
    local n=${1:-"9999"}
    echo "GPU Memory Usage:"
    local FIRST_N_GPU_IDS=$(nvidia-smi --query-gpu=memory.used --format=csv \
        | tail -n +2 \
        | nl -v 0 \
        | tee /dev/tty \
        | sort -g -k 2 \
        | awk '{print $1}' \
        | head -n $n)
    export CUDA_VISIBLE_DEVICES=$(echo $FIRST_N_GPU_IDS | sed 's/ /,/g')
    echo "Now CUDA_VISIBLE_DEVICES is set to:"
    echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
}

set_n_least_used_CUDA_VISIBLE_DEVICES ${NUM_GPUS}
# export HUGGINGFACE_HUB_CACHE="/nvme/model-weights/hub" # or `ln -s /nvme/model-weights/hub/model--* ~/.cache/huggingface/hub/`

export BASE=$(realpath $(dirname $0))
export PROMPT_DATASET=${BASE}/InstructionWild/data_v2/user_1.jsonl # https://github.com/XueFuzhao/InstructionWild.git
export PRETRAIN_DATASET=${BASE}/InstructionWild/data/instinwild_en.json # https://github.com/XueFuzhao/InstructionWild.git

torchrun --standalone \
    --nproc_per_node=${NUM_GPUS} \
    "${BASE}/train_prompts.py" \
        --max_seq_len 512 \
        --train_batch_size 4 \
        --experience_batch_size 4 \
        --model opt \
        --pretrain facebook/opt-1.3b \
        --rm_model opt \
        --rm_pretrain facebook/opt-350m \
        --prompt_dataset $PROMPT_DATASET \
        --pretrain_dataset $PRETRAIN_DATASET \
        --strategy ${TRAINER_STRATEGY} \
        2>&1 | tee -a $COATI_LOG_FILE
        # --strategy naive
        # --strategy colossalai_gemini
        # --strategy colossalai_zero2
        # --model llama \
        # --pretrain "huggyllama/llama-7b" \
        # --rm_model llama \
        # --rm_pretrain "huggyllama/llama-7b" \
        # --model bloom \
        # --pretrain "bigscience/bloom-560m" \
        # --rm_model bloom \
        # --rm_pretrain "bigscience/bloom-560m" \
