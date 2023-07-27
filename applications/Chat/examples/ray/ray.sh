#!/bin/bash

function up() {
export RAY_PROMETHEUS_HOST="http://10.122.23.21:31926"
export RAY_GRAFANA_HOST="http://10.122.23.21:31780"
export RAY_GRAFANA_IFRAME_HOST="http://10.122.23.21:31780"
ray start --head \
    --num-cpus 48 \
    --num-gpus 8 \
    --include-dashboard true \
    --dashboard-host 0.0.0.0 \
    --dashboard-port 8265 \
    --metrics-export-port=8080 \
    --temp-dir=/nvme/ray
}

function down() {
    ray stop
}

function run() {
    # pwd: .../ColossalAI/applications/Chat
    bash examples/ray/test_ci.sh
}

function dockerRun() {
DOCKER_IMAGE=10.140.0.107:8090/llm/colossalai:0.3.0
docker run -d \
    --runtime=nvidia \
    --name=wqzcolov1 \
    -e NVIDIA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 \
    -v /home/wengqizhen/Workspace:/wks \
    -v /nvme:/nvme \
    --ipc="host" \
    --network="host" \
    ${DOCKER_IMAGE} bash -c "sleep infinity"
}

$@