CPU Benchmark
===

__Configuration__

* lambda stack (tf version 1.9.0)
* Benchmark code: Based on TF's [benchmarks](https://github.com/tensorflow/benchmarks) (GitHub hash 9165a70).

Notice: 9165a70 is used in https://www.tensorflow.org/performance/benchmarks. Minor modifications are made in this repo to be consistent in image resizing for distortion and non-distortion modes. 


__Instructions__

Prepare Imagenet data. Here is a [link](https://drive.google.com/open?id=1JzF24uUa7D9fFeETrnNYMMMZ-9yNC0I5) to download a fraction of imagenet. Download and unzip it into ```~/data/imagenet_mini```

```
cd scripts/tf_cnn_benchmarks
./cpu_benchmark.sh
./cpu_report.sh
```

The results will be saved as ```summary.md```
