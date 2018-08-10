#!/bin/bash -e

SUMMARY_NAME="../../summary.md"

CPU_NAME="$(lscpu | grep "Model name:" | sed -r 's/Model name:\s{1,}//g' | awk '{ print $4 }')";

ITERATIONS=2

DATA_DIR="/home/${USER}/data/imagenet_mini"
SCRIPT_DIR="/home/${USER}/git/tf-benchmarks-ref/scripts/tf_cnn_benchmarks"


DATA_NAME=imagenet

MODELS=(
  resnet50
  resnet101
  resnet152
  inception3
  inception4
  vgg16
  alexnet
)


CPU_NAMES=(
  i7-7820X
  W-2133
  E5-1650
  1950X
  i9-7900X
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


get_benchmark_name() {

  local num_gpus=$1
  local data_mode=$2
  local variable_update=$3
  local use_nccl=$4
  local distortions=$5

  local benchmark_name="${data_mode}-${variable_update}"

  if $use_nccl; then
    benchmark_name+="-nccl"
  fi

  if $distortions; then
    benchmark_name+="-distortions"
  fi
  benchmark_name+="-${num_gpus}gpus"
  echo $benchmark_name
}

run_report() {
  local model=$1
  local batch_size=$2
  local cpu_name=$3
  local num_gpus=$4
  local iter=$5
  local data_mode=$6
  local variable_update=$7
  local use_nccl=$8
  local distortions=$9

  local output="${LOG_DIR}/${model}-${data_mode}-${variable_update}"

  if $use_nccl; then
    output+="-nccl"
  fi

  if $distortions; then
    output+="-distortions"
  fi
  output+="-${num_gpus}gpus-${batch_size}-${iter}.log"

  if [ ! -f ${output} ]; then
    image_per_sec=0
  else
    image_per_sec=$(cat ${output}|grep total\ images | awk '{ print $3 }' | bc -l)
  fi
  
  echo $image_per_sec

}

main() {
  local data_mode variable_update distortion_mode model num_gpus iter benchmark_name use_nccl distortions
  local cpu_line table_line
  echo "SUMMARY" > $SUMMARY_NAME
  echo "===" >> $SUMMARY_NAME

  echo "| model | input size | param mem | feat. mem | flops | performance |" >> $SUMMARY_NAME
  echo "|-------|------------|--------------|----------------|-------|-------------|" >> $SUMMARY_NAME
  echo "| [resnet-50](reports/resnet-50.md) | 224 x 224 | 98 MB | 103 MB | 4 BFLOPs | 24.60 / 7.70 |" >> $SUMMARY_NAME
  echo "| [resnet-101](reports/resnet-101.md) | 224 x 224 | 170 MB | 155 MB | 8 BFLOPs | 23.40 / 7.00 |" >> $SUMMARY_NAME
  echo "| [resnet-152](reports/resnet-152.md) | 224 x 224 | 230 MB | 219 MB | 11 BFLOPs | 23.00 / 6.70 |" >> $SUMMARY_NAME  
  echo "| [inception-v3](reports/inception-v3.md) | 299 x 299 | 91 MB | 89 MB | 6 BFLOPs | 22.55 / 6.44 |" >> $SUMMARY_NAME
  echo "| [vgg-vd-19](reports/vgg-vd-19.md) | 224 x 224 | 548 MB | 63 MB | 20 BFLOPs | 28.70 / 9.90 |" >> $SUMMARY_NAME
  echo "| [alexnet](reports/alexnet.md) | 227 x 227 | 233 MB | 3 MB | 1.5 BFLOPs | 41.80 / 19.20 |" >> $SUMMARY_NAME

  cpu_line="CPU |"
  table_line=":------:|"
  for cpu_name in "${CPU_NAMES[@]}"; do
    cpu_line+=" ${cpu_name} |"
    table_line+=":------:|"
  done

  for num_gpus in `seq ${MAX_NUM_GPU} -1 ${MIN_NUM_GPU}`; do 
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
                benchmark_name=$(get_benchmark_name $num_gpus $data_mode $variable_update $use_nccl $distortions)
              
                echo $'\n' >> $SUMMARY_NAME
                echo "**${benchmark_name}**"$'\n' >> $SUMMARY_NAME
                echo "${cpu_line}" >> $SUMMARY_NAME
                echo "${table_line}" >> $SUMMARY_NAME
                    
                for model in "${MODELS[@]}"; do
                  local batch_size=${BATCH_SIZES[$model]}
                  result_line="${model} |"
                  for cpu_name in "${CPU_NAMES[@]}"; do

                    LOG_DIR="/home/${USER}/imagenet_benchmark_logs/${cpu_name}"

                    result=0

                    for iter in $(seq 1 $ITERATIONS); do
                      image_per_sec=$(run_report "$model" $batch_size $cpu_name $num_gpus $iter $data_mode $variable_update $use_nccl $distortions)
                      result=$(echo "$result + $image_per_sec" | bc -l)
                    done
                    result=$(echo "scale=2; $result / $ITERATIONS" | bc -l)
                    result_line+="${result} |"

                  done
                  
                  echo "${result_line}" >> $SUMMARY_NAME
                done 

              fi
            fi
          done
        done
      done
    done
  done


}

main "$@"