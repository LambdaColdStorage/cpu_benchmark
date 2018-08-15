SUMMARY
===
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
resnet50 |0 |0 |0 | |764.45 |
resnet101 |0 |0 |0 | |444.68 |
resnet152 |0 |0 |0 | |279.64 |
inception3 |0 |0 |0 | |474.89 |
inception4 |0 |0 |0 |181.08 |186.67 |
vgg16 |0 |0 |0 |342.67 |416.89 |
alexnet |0 |0 |0 |6815.54 |8483.71 |


**syn-replicated-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |0 |0 |0 |739.31 |774.27 |
resnet101 |0 |0 |0 |449.91 |470.93 |
resnet152 |0 |0 |0 | |306.62 |
inception3 |0 |0 |0 |473.94 |498.95 |
inception4 |0 |0 |0 | |205.33 |
vgg16 |0 |0 |0 | |411.03 |
alexnet |0 |0 |0 |6816.99 |8814.74 |


**real-parameter_server-distortions-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |0 |0 |0 | |734.45 |
resnet101 |0 |0 |0 | |438.62 |
resnet152 |0 |0 |0 | |269.80 |
inception3 |0 |0 |0 | |470.89 |
inception4 |0 |0 |0 | |183.72 |
vgg16 |0 |0 |0 | |407.39 |
alexnet |0 |0 |0 | |3407.29 |


**real-parameter_server-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |0 |0 |0 | |741.31 |
resnet101 |0 |0 |0 |423.79 |438.12 |
resnet152 |0 |0 |0 |268.64 |279.41 |
inception3 |0 |0 |0 | |473.27 |
inception4 |0 |0 |0 | |190.41 |
vgg16 |0 |0 |0 |336.96 |405.97 |
alexnet |0 |0 |0 | |5298.45 |


**real-replicated-distortions-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |0 |0 |0 |637.15 |760.31 |
resnet101 |0 |0 |0 | |466.99 |
resnet152 |0 |0 |0 | |302.61 |
inception3 |0 |0 |0 | |497.95 |
inception4 |0 |0 |0 | |204.09 |
vgg16 |0 |0 |0 |285.27 |369.76 |
alexnet |0 |0 |0 | |3375.17 |


**real-replicated-4gpus**

CPU | i7-7820X | W-2133 | E5-1650 | 1950X | i9-7900X |
:------:|:------:|:------:|:------:|:------:|:------:|
resnet50 |0 |0 |0 | |762.19 |
resnet101 |0 |0 |0 | |468.62 |
resnet152 |0 |0 |0 | |304.21 |
inception3 |0 |0 |0 | |494.97 |
inception4 |0 |0 |0 | |203.86 |
vgg16 |0 |0 |0 |282.95 |367.78 |
alexnet |0 |0 |0 | |5239.91 |
