python tf_cnn_benchmarks.py --model=alexnet --optimizer=sgd --num_gpus=4 --batch_size=512 --variable_update=replicated --num_batches=100 --data_dir=/home/${USER}/data/imagenet_mini --distortions=True
