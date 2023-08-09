#!/bin/bash

function rayUp() {
export RAY_PROMETHEUS_HOST="http://10.122.23.21:31926"
export RAY_GRAFANA_HOST="http://10.122.23.21:31780"
export RAY_GRAFANA_IFRAME_HOST="http://10.122.23.21:31780"
export NCCL_SOCKET_IFNAME="tunl0"
ray start --head \
    --num-cpus 48 \
    --num-gpus 8 \
    --include-dashboard true \
    --dashboard-host 0.0.0.0 \
    --dashboard-port 8265 \
    --metrics-export-port=8080 \
    --temp-dir=/nvme/ray
}

function rayJoin() {
export NCCL_SOCKET_IFNAME="tunl0"
ray start --address $1 \
    --num-cpus 48 \
    --num-gpus 8 \
    --temp-dir=/nvme/ray
}

function rayDown() {
    ray stop
}

function rayRun() {
    # pwd: .../ColossalAI/applications/Chat
    bash examples/ray/test_ci.sh
}

function prompt() {
    bash examples/train_prompts.sh
}

function buildCache() {
    mkdir -p ~/.cache/huggingface/
    ln -s /nvme/model-weights/hub ~/.cache/huggingface/
}

function testGemini() {
    python examples/ray/test_gemini.py
}

function fixGemini() {
    echo "Hi"
}

function testBuild() {
    python examples/ray/test_build.py
}

function dockerRun() {
# DOCKER_IMAGE=10.140.0.107:8090/llm/colossalai:0.3.0
DOCKER_IMAGE=10.140.0.107:8090/llm/colossalai:0.3.0v0807
sudo docker run -d \
    --runtime=nvidia \
    --name=wqzcolov3 \
    --memory=300G \
    --gpus 8 \
    -v /home/wengqizhen/Workspace:/wks \
    -v /nvme:/nvme \
    --ipc="host" \
    --network="host" \
    ${DOCKER_IMAGE} bash -c "sleep infinity"
    # -e NVIDIA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 \
}

$@