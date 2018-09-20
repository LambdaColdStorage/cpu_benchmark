Benchmark
===

Step One: Download mini imagenet (1.5 G)

```
(mkdir ~/data;
curl https://s3-us-west-2.amazonaws.com/lambdalabs-files/imagenet_mini.tar.gz | tar xvz -C ~/data)
```

Step Two: Clone repo (Clone to the home directory if it is possible)

```
git clone https://github.com/lambdal/cpu_benchmark.git
cd cpu_benchmark
git checkout tensorflow-1.8
cd scripts/tf_cnn_benchmarks
```

Step Three: Only need if you didn't clone the repo to the home directory

Change the SCRIPT_DIR variable in cpu_benchmark.sh so it points to the folder "cpu_benchmark/scripts/tf_cnn_benchmarks".


Step Four: Benchmark (This will take a couple of hours)

```
./cpu_benchmark.sh
```

Step Five (Please send us back the summary.md file in the cpu_benchmark folder)

```
./cpu_report.sh
```