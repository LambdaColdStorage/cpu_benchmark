#!/bin/bash -e

SUMMARY_NAME="/home/${USER}/imagenet_benchmark_logs/summary.md"

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
  # echo "| [caffenet](reports/caffenet.md) | 224 x 224 | 233 MB | 3 MB | 724 MFLOPs | MCN | 42.60 / 19.70 |" >> $SUMMARY_NAME
  # echo "| [squeezenet1-0](reports/squeezenet1-0.md) | 224 x 224 | 5 MB | 30 MB | 837 MFLOPs | PT | 41.90 / 19.58 |" >> $SUMMARY_NAME
  # echo "| [squeezenet1-1](reports/squeezenet1-1.md) | 224 x 224 | 5 MB | 17 MB | 360 MFLOPs | PT | 41.81 / 19.38 |" >> $SUMMARY_NAME
  # echo "| [vgg-f](reports/vgg-f.md) | 224 x 224 | 232 MB | 4 MB | 727 MFLOPs | MCN | 41.40 / 19.10 |" >> $SUMMARY_NAME
  # echo "| [vgg-m](reports/vgg-m.md) | 224 x 224 | 393 MB | 12 MB | 2 GFLOPs | MCN | 36.90 / 15.50 |" >> $SUMMARY_NAME
  # echo "| [vgg-s](reports/vgg-s.md) | 224 x 224 | 393 MB | 12 MB | 3 GFLOPs | MCN | 37.00 / 15.80 |" >> $SUMMARY_NAME
  # echo "| [vgg-m-2048](reports/vgg-m-2048.md) | 224 x 224 | 353 MB | 12 MB | 2 GFLOPs | MCN | 37.10 / 15.80 |" >> $SUMMARY_NAME
  # echo "| [vgg-m-1024](reports/vgg-m-1024.md) | 224 x 224 | 333 MB | 12 MB | 2 GFLOPs | MCN | 37.80 / 16.10 |" >> $SUMMARY_NAME
  # echo "| [vgg-m-128](reports/vgg-m-128.md) | 224 x 224 | 315 MB | 12 MB | 2 GFLOPs | MCN | 40.80 / 18.40 |" >> $SUMMARY_NAME
  # echo "| [vgg-vd-16-atrous](reports/vgg-vd-16-atrous.md) | 224 x 224 | 82 MB | 58 MB | 16 GFLOPs | N/A | - / -  |" >> $SUMMARY_NAME
  # echo "| [vgg-vd-16](reports/vgg-vd-16.md) | 224 x 224 | 528 MB | 58 MB | 16 GFLOPs | MCN | 28.50 / 9.90 |" >> $SUMMARY_NAME
  
  # echo "| [googlenet](reports/googlenet.md) | 224 x 224 | 51 MB | 26 MB | 2 GFLOPs | MCN | 34.20 / 12.90 |" >> $SUMMARY_NAME
  # echo "| [resnet18](reports/resnet18.md) | 224 x 224 | 45 MB | 23 MB | 2 GFLOPs | PT | 30.24 / 10.92 |" >> $SUMMARY_NAME
  # echo "| [resnet34](reports/resnet34.md) | 224 x 224 | 83 MB | 35 MB | 4 GFLOPs | PT | 26.70 / 8.58 |" >> $SUMMARY_NAME

  # echo "| [resnext-50-32x4d](reports/resnext-50-32x4d.md) | 224 x 224 | 96 MB | 132 MB | 4 GFLOPs | L1 | 22.60 / 6.49 |" >> $SUMMARY_NAME
  # echo "| [resnext-101-32x4d](reports/resnext-101-32x4d.md) | 224 x 224 | 169 MB | 197 MB | 8 GFLOPs | L1 | 21.55 / 5.93 |" >> $SUMMARY_NAME
  # echo "| [resnext-101-64x4d](reports/resnext-101-64x4d.md) | 224 x 224 | 319 MB | 273 MB | 16 GFLOPs | PT | 20.81 / 5.66 |" >> $SUMMARY_NAME
  
  # echo "| [SE-ResNet-50](reports/SE-ResNet-50.md) | 224 x 224 | 107 MB | 103 MB | 4 GFLOPs | SE | 22.37 / 6.36 |" >> $SUMMARY_NAME
  # echo "| [SE-ResNet-101](reports/SE-ResNet-101.md) | 224 x 224 | 189 MB | 155 MB | 8 GFLOPs | SE | 21.75 / 5.72 |" >> $SUMMARY_NAME
  # echo "| [SE-ResNet-152](reports/SE-ResNet-152.md) | 224 x 224 | 255 MB | 220 MB | 11 GFLOPs | SE | 21.34 / 5.54 |" >> $SUMMARY_NAME
  # echo "| [SE-ResNeXt-50-32x4d](reports/SE-ResNeXt-50-32x4d.md) | 224 x 224 | 105 MB | 132 MB | 4 GFLOPs | SE | 20.97 / 5.54 |" >> $SUMMARY_NAME
  # echo "| [SE-ResNeXt-101-32x4d](reports/SE-ResNeXt-101-32x4d.md) | 224 x 224 | 187 MB | 197 MB | 8 GFLOPs | SE | 19.81 / 4.96 |" >> $SUMMARY_NAME
  # echo "| [SENet](reports/SENet.md) | 224 x 224 | 440 MB | 347 MB | 21 GFLOPs | SE | 18.68 / 4.47 |" >> $SUMMARY_NAME
  # echo "| [SE-BN-Inception](reports/SE-BN-Inception.md) | 224 x 224 | 46 MB | 43 MB | 2 GFLOPs | SE | 23.62 / 7.04 |" >> $SUMMARY_NAME
  # echo "| [densenet121](reports/densenet121.md) | 224 x 224 | 31 MB | 126 MB | 3 GFLOPs | PT | 25.35 / 7.83 |" >> $SUMMARY_NAME
  # echo "| [densenet161](reports/densenet161.md) | 224 x 224 | 110 MB | 235 MB | 8 GFLOPs | PT | 22.35 / 6.20 |" >> $SUMMARY_NAME
  # echo "| [densenet169](reports/densenet169.md) | 224 x 224 | 55 MB | 152 MB | 3 GFLOPs | PT | 24.00 / 7.00 |" >> $SUMMARY_NAME
  # echo "| [densenet201](reports/densenet201.md) | 224 x 224 | 77 MB | 196 MB | 4 GFLOPs | PT | 22.80 / 6.43 |" >> $SUMMARY_NAME




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