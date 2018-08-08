#!/bin/bash

MODEL=inception3

DIR_DATA='/mnt/data500G/data/imagenet'
# DIR_DATA='/home/oem/data/imagenet_mini'
# DIR_DATA='/home/ubuntu/data/imagenet_mini'

CPU_NAME=Xeon-E5-2620-v3
# CPU_NAME=i7-7820 
# CPU_NAME=Xeon-W2133 
# CPU_NAME=Xeon-1650v4


# -----------------------------------
# GPU benchmark
# -----------------------------------
BATCH_SIZE=64
NUM_GPU=4
NUM_BATCHES=200

for NUM_GPU in 4
do

  for UPDATE_MODE in parameter_server
  do
    echo ${CPU_NAME}_${MODEL}_syn_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_${UPDATE_MODE}
    python tf_cnn_benchmarks.py \
    --num_gpus=$NUM_GPU \
    --batch_size=$BATCH_SIZE \
    --model=$MODEL \
    --variable_update=$UPDATE_MODE \
    --local_parameter_device=cpu \
    --num_batches=$NUM_BATCHES \
    &> ${CPU_NAME}_${MODEL}_syn_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_${UPDATE_MODE}.log
  done

  for UPDATE_MODE in replicated
  do
    echo ${CPU_NAME}_${MODEL}_syn_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_${UPDATE_MODE}
    python tf_cnn_benchmarks.py \
    --num_gpus=$NUM_GPU \
    --batch_size=$BATCH_SIZE \
    --model=$MODEL \
    --variable_update=$UPDATE_MODE \
    --num_batches=$NUM_BATCHES \
    --use_nccl=False \
    &> ${CPU_NAME}_${MODEL}_syn_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_${UPDATE_MODE}.log
  done

  for UPDATE_MODE in replicated
  do
    echo ${CPU_NAME}_${MODEL}_syn_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_${UPDATE_MODE}_nccl
    python tf_cnn_benchmarks.py \
    --num_gpus=$NUM_GPU \
    --batch_size=$BATCH_SIZE \
    --model=$MODEL \
    --variable_update=$UPDATE_MODE \
    --num_batches=$NUM_BATCHES \
    --use_nccl=True \
    &> ${CPU_NAME}_${MODEL}_syn_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_${UPDATE_MODE}_nccl.log
  done

done


for NUM_GPU in 4
do

  for UPDATE_MODE in parameter_server
  do
    for DISTORTIONS in True False
    do
      echo ${CPU_NAME}_${MODEL}_real_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_distortions_${DISTORTIONS}_${UPDATE_MODE}
      python tf_cnn_benchmarks.py \
      --num_gpus=$NUM_GPU \
      --batch_size=$BATCH_SIZE \
      --model=$MODEL \
      --variable_update=$UPDATE_MODE \
      --local_parameter_device=cpu \
      --distortions=$DISTORTIONS \
      --num_batches=$NUM_BATCHES \
      --data_dir=$DIR_DATA \
      &> ${CPU_NAME}_${MODEL}_real_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_distortions_${DISTORTIONS}_${UPDATE_MODE}.log
    done
  done

  for UPDATE_MODE in replicated
  do
    for DISTORTIONS in True False
    do
      echo ${CPU_NAME}_${MODEL}_real_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_distortions_${DISTORTIONS}_${UPDATE_MODE}
      python tf_cnn_benchmarks.py \
      --num_gpus=$NUM_GPU \
      --batch_size=$BATCH_SIZE \
      --model=$MODEL \
      --variable_update=$UPDATE_MODE \
      --local_parameter_device=cpu \
      --distortions=$DISTORTIONS \
      --num_batches=$NUM_BATCHES \
      --data_dir=$DIR_DATA \
      --use_nccl=False \
      &> ${CPU_NAME}_${MODEL}_real_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_distortions_${DISTORTIONS}_${UPDATE_MODE}.log
    done
  done

  for UPDATE_MODE in replicated
  do
    for DISTORTIONS in True False
    do
      echo ${CPU_NAME}_${MODEL}_real_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_distortions_${DISTORTIONS}_${UPDATE_MODE}_nccl
      python tf_cnn_benchmarks.py \
      --num_gpus=$NUM_GPU \
      --batch_size=$BATCH_SIZE \
      --model=$MODEL \
      --variable_update=$UPDATE_MODE \
      --local_parameter_device=cpu \
      --distortions=$DISTORTIONS \
      --num_batches=$NUM_BATCHES \
      --data_dir=$DIR_DATA \
      --use_nccl=True \
      &> ${CPU_NAME}_${MODEL}_real_bs_${BATCH_SIZE}_gpu_${NUM_GPU}_distortions_${DISTORTIONS}_${UPDATE_MODE}_nccl.log
    done
  done

done

# -----------------------------------
# CPU benchmark
# -----------------------------------
BATCH_SIZE=1

for DISTORTIONS in True False
do
  echo ${CPU_NAME}_${MODEL}_syn_bs_${BATCH_SIZE}_distortions_${DISTORTIONS}
  python tf_cnn_benchmarks.py --device=cpu \
  --batch_size=$BATCH_SIZE --model=$MODEL \
  --data_format=NHWC \
  --num_warmup_batches=0 \
  --distortions=$DISTORTIONS \
  --num_batches=$NUM_BATCHES \
  &> ${CPU_NAME}_${MODEL}_syn_bs_${BATCH_SIZE}_distortions_${DISTORTIONS}.log
done

for DISTORTIONS in True False
do
  echo ${CPU_NAME}_${MODEL}_real_bs_${BATCH_SIZE}_distortions_${DISTORTIONS}
  python tf_cnn_benchmarks.py --device=cpu \
  --batch_size=$BATCH_SIZE --model=$MODEL \
  --data_format=NHWC \
  --num_warmup_batches=0 \
  --distortions=$DISTORTIONS \
  --data_dir=$DIR_DATA \
  --num_batches=$NUM_BATCHES \
  &> ${CPU_NAME}_${MODEL}_real_bs_${BATCH_SIZE}_distortions_${DISTORTIONS}.log
done
