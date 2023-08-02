NUM_GPUS=8

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

BASE=$(realpath $(dirname $0))
export PROMPT_DATASET=${BASE}/InstructionWild/data_v2/user_1.jsonl # https://github.com/XueFuzhao/InstructionWild.git
export PRETRAIN_DATASET=${BASE}/InstructionWild/data/instinwild_en.json # https://github.com/XueFuzhao/InstructionWild.git

torchrun --standalone \
    --nproc_per_node=${NUM_GPUS} \
    "${BASE}/train_prompts.py" \
        --model bloom \
        --pretrain "bigscience/bloom-560m" \
        --prompt_dataset $PROMPT_DATASET \
        --pretrain_dataset $PRETRAIN_DATASET \
        --strategy colossalai_zero2
