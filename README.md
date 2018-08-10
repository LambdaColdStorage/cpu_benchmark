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

The results will be saved as ```summary.md```.

__Results__

| model | input size | param mem | feat. mem | flops | performance |
|-------|------------|--------------|----------------|-------|-------------|
| [resnet-50](reports/resnet-50.md) | 224 x 224 | 98 MB | 103 MB | 4 BFLOPs | 24.60 / 7.70 |
| [resnet-101](reports/resnet-101.md) | 224 x 224 | 170 MB | 155 MB | 8 BFLOPs | 23.40 / 7.00 |
| [resnet-152](reports/resnet-152.md) | 224 x 224 | 230 MB | 219 MB | 11 BFLOPs | 23.00 / 6.70 |
| [inception-v3](reports/inception-v3.md) | 299 x 299 | 91 MB | 89 MB | 6 BFLOPs | 22.55 / 6.44 |
| [vgg-vd-19](reports/vgg-vd-19.md) | 224 x 224 | 548 MB | 63 MB | 20 BFLOPs | 28.70 / 9.90 |
| [alexnet](reports/alexnet.md) | 227 x 227 | 233 MB | 3 MB | 1.5 BFLOPs | 41.80 / 19.20 |


**syn-parameter_server-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |726.86 |734.73 |757.49 |0 |732.31 |
resnet101 |433.68 |439.40 |454.50 |0 |435.59 |
resnet152 |263.12 |248.38 |287.29 |0 |267.31 |
inception3 |456.12 |437.41 |486.17 |0 |471.10 |
inception4 |172.45 |147.73 |192.97 |0 |186.46 |
vgg16 |377.88 |287.04 |351.15 |0 |398.75 |
alexnet |7851.70 |5337.62 |7422.44 |0 |8560.16 |


**syn-replicated-nccl-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |645.91 |556.81 |717.25 |0 |709.40 |
resnet101 |394.92 |332.57 |433.22 |0 |429.26 |
resnet152 |227.73 |168.79 |255.40 |0 |269.55 |
inception3 |460.54 |417.68 |481.66 |0 |476.83 |
inception4 |164.10 |122.98 |192.26 |0 |192.90 |
vgg16 |336.40 |220.96 |406.39 |0 |452.37 |
alexnet |7319.59 |4455.51 |8133.18 |0 |9134.50 |


**syn-replicated-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |732.33 |660.22 |757.64 |0 |743.17 |
resnet101 |462.65 |409.23 |473.74 |0 |465.85 |
resnet152 |304.43 |254.57 |318.96 |0 |312.95 |
inception3 |479.00 |405.83 |491.01 |0 |484.76 |
inception4 |192.88 |122.33 |207.20 |0 |209.72 |
vgg16 |361.00 |283.85 |362.47 |0 |402.72 |
alexnet |7420.59 |5353.39 |7323.28 |0 |8338.36 |


**real-parameter_server-distortions-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |707.75 |610.46 |735.68 |0 |718.33 |
resnet101 |440.77 |381.53 |451.07 |0 |438.98 |
resnet152 |261.54 |224.70 |260.22 |0 |271.49 |
inception3 |458.17 |420.08 |484.73 |0 |468.97 |
inception4 |169.22 |144.47 |175.85 |0 |183.43 |
vgg16 |368.94 |267.68 |350.26 |0 |395.14 |
alexnet |1999.32 |1473.50 |1453.04 |0 |2335.69 |


**real-parameter_server-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |628.26 |620.34 |607.05 |0 |659.93 |
resnet101 |384.73 |379.31 |382.52 |0 |381.28 |
resnet152 |252.42 |227.91 |250.04 |0 |257.73 |
inception3 |402.21 |420.73 |432.15 |0 |417.25 |
inception4 |171.19 |138.30 |171.73 |0 |180.42 |
vgg16 |366.96 |270.62 |347.43 |0 |394.45 |
alexnet |2746.50 |2063.17 |2006.84 |0 |3057.96 |


**real-replicated-nccl-distortions-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |679.11 |558.13 |716.52 |0 |718.25 |
resnet101 |403.28 |327.42 |433.37 |0 |433.60 |
resnet152 |227.99 |173.01 |259.64 |0 |270.69 |
inception3 |463.36 |417.14 |482.00 |0 |477.67 |
inception4 |163.28 |122.68 |192.48 |0 |189.76 |
vgg16 |336.16 |219.51 |406.35 |0 |448.65 |
alexnet |2007.64 |1463.27 |1450.59 |0 |2316.19 |


**real-replicated-nccl-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |671.71 |556.05 |717.71 |0 |713.31 |
resnet101 |391.38 |321.49 |431.07 |0 |426.81 |
resnet152 |222.88 |169.82 |262.86 |0 |265.15 |
inception3 |459.94 |411.36 |483.37 |0 |471.81 |
inception4 |162.33 |122.27 |189.82 |0 |189.14 |
vgg16 |377.51 |230.67 |390.68 |0 |426.98 |
alexnet |2722.86 |2028.27 |1998.99 |0 |3023.18 |


**real-replicated-distortions-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |741.84 |667.44 |759.36 |0 |752.96 |
resnet101 |471.75 |418.84 |472.70 |0 |472.05 |
resnet152 |309.55 |257.24 |318.34 |0 |314.58 |
inception3 |479.85 |404.88 |496.96 |0 |486.80 |
inception4 |193.29 |122.13 |205.05 |0 |205.14 |
vgg16 |365.20 |285.22 |365.74 |0 |406.38 |
alexnet |2003.85 |1434.63 |1447.70 |0 |2336.29 |


**real-replicated-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |730.63 |641.99 |749.90 |0 |742.28 |
resnet101 |455.99 |402.69 |456.38 |0 |461.28 |
resnet152 |302.42 |252.25 |316.49 |0 |308.00 |
inception3 |479.59 |401.39 |486.99 |0 |485.35 |
inception4 |191.13 |121.90 |204.45 |0 |204.38 |
vgg16 |357.48 |275.43 |350.18 |0 |403.10 |
alexnet |2732.90 |1981.72 |2006.08 |0 |3040.95 |

