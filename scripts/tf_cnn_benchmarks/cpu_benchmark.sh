#!/bin/bash -e

CPU_NAME="$(lscpu | grep "Model name:" | sed -r 's/Model name:\s{1,}//g' | awk '{ print $4 }')";
if [ $CPU_NAME = "CPU" ]; then
  # CPU can show up at different locations
  CPU_NAME="$(lscpu | grep "Model name:" | sed -r 's/Model name:\s{1,}//g' | awk '{ print $3 }')";
fi
echo $CPU_NAME

ITERATIONS=2
NUM_BATCHES=20

DATA_DIR="/home/${USER}/data/imagenet_mini"
SCRIPT_DIR="/home/${USER}/git/tf-benchmarks-ref/scripts/tf_cnn_benchmarks"
LOG_DIR="/home/${USER}/imagenet_benchmark_logs/${CPU_NAME}"

MODELS=(
  resnet50
  resnet101
  resnet152
  inception3
  inception4
  vgg16
  alexnet
)

VARIABLE_UPDATE=(
  parameter_server
  replicated
)

DATA_MODE=(
  syn
  real
)

declare -A BATCH_SIZES=(
  [resnet50]=64
  [resnet101]=64
  [resnet152]=32
  [inception3]=64
  [inception4]=16
  [vgg16]=64
  [alexnet]=512
)

MIN_NUM_GPU=4
MAX_NUM_GPU=4

run_benchmark() {

  local model="$1"
  local batch_size=$2
  local cpu_name=$3
  local num_gpus=$4
  local iter=$5
  local data_mode=$6
  local update_mode=$7
  local use_nccl=$8
  local distortions=$9

  pushd "$SCRIPT_DIR" &> /dev/null
  local args=()
  local output="${LOG_DIR}/${model}-${data_mode}-${variable_update}"

  args+=("--optimizer=sgd")
  args+=("--model=$model")
  args+=("--num_gpus=$num_gpus")
  args+=("--batch_size=$batch_size")
  args+=("--variable_update=$variable_update")
  args+=("--distortions=$distortions")
  args+=("--num_batches=$NUM_BATCHES")

  if [ $data_mode = real ]; then
    args+=("--data_dir=$DATA_DIR")
  fi
  if $use_nccl; then
    args+=("--use_nccl")
    output+="-nccl"
  fi

  if $distortions; then
    output+="-distortions"
  fi
  output+="-${num_gpus}gpus-${batch_size}-${iter}.log"

  mkdir -p "${LOG_DIR}" || true
  
  echo $output
  unbuffer python tf_cnn_benchmarks.py "${args[@]}" |& tee "$output"
  popd &> /dev/null
}

run_benchmark_all() {
  local data_mode="$1" 
  local variable_update="$2"
  local use_nccl="$3"
  local distortions="$4"

  for model in "${MODELS[@]}"; do
    local batch_size=${BATCH_SIZES[$model]}
    for num_gpu in `seq ${MAX_NUM_GPU} -1 ${MIN_NUM_GPU}`; do 
      for iter in $(seq 1 $ITERATIONS); do
        run_benchmark "$model" $batch_size $CPU_NAME $num_gpu $iter $data_mode $variable_update $use_nccl $distortions
      done
    done
  done  
}

main() {
  local data_mode variable_update distortion_mode model num_gpu iter benchmark_name use_nccl distortions
  local cpu_line table_line

  for data_mode in "${DATA_MODE[@]}"; do
    for variable_update in "${VARIABLE_UPDATE[@]}"; do
      for use_nccl in true false; do
        for distortions in true false; do
          if [ $variable_update = parameter_server ] && $use_nccl ; then
            # skip nccl for parameter_server
            :
          else
            if [ $data_mode = syn ] && $distortions ; then
              # skip distortion for synthetic data
              :
            else
              run_benchmark_all $data_mode $variable_update $use_nccl $distortions
            fi
          fi
        done
      done
    done
  done

}

main "$@"