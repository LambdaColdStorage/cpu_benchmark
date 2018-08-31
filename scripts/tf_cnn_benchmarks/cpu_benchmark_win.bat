@ECHO OFF
SETLOCAL EnableDelayedExpansion
set CPU_NAME=6850K-WIN

set ITERATIONS=2
set NUM_BATCHES=100

set DATA_DIR=%USERPROFILE%\data\imagenet_mini
set SCRIPT_DIR=%USERPROFILE%\cpu_benchmark\scripts\tf_cnn_benchmarks
set LOG_DIR=%USERPROFILE%\imagenet_benchmark_logs\%CPU_NAME%

set MODELS=resnet50 resnet101 resnet152 inception3 inception4 vgg16 alexnet

set VARIABLE_UPDATE=parameter_server replicated

set DATA_MODE=syn real

set BATCH_SIZES[resnet50]=64
set BATCH_SIZES[resnet101]=64
set BATCH_SIZES[resnet152]=32
set BATCH_SIZES[inception3]=64
set BATCH_SIZES[inception4]=16
set BATCH_SIZES[vgg16]=64
set BATCH_SIZES[alexnet]=512

set MIN_NUM_GPU=4
set MAX_NUM_GPU=4

GOTO :MAIN

:Display 
echo %~1 %~2 %~3
EXIT /B 0

:run_benchmark
SETLOCAL
set model=%~1
set batch_size=%~2
set cpu_name=%~3
set num_gpus=%~4
set iter=%~5
set data_mode=%~6
set update_mode=%~7
set distortions=%~8

set output=%LOG_DIR%\%model%-%data_mode%-%variable_update%

set p1=--optimizer=sgd
set p2=--model=%model%
set p3=--num_gpus=%num_gpus%
set p4=--batch_size=%batch_size%
set p5=--variable_update=%variable_update%
set p6=--distortions=%distortions%
set p7=--num_batches=%NUM_BATCHES%
set p8=
set p9=

IF "%data_mode%"=="real" (
  set p8=--data_dir=%DATA_DIR%
)

IF "%distortions%"=="true" (
  set p9=-distortions
  set output=%output%-distortions
)

set output=%output%-%num_gpus%gpus-%batch_size%-%iter%.log
echo %output%

if not exist %LOG_DIR% mkdir %LOG_DIR%

echo %p1% %p2% %p3% %p4% %p5% %p6% %p7% %p8% %p9%
python tf_cnn_benchmarks.py %p1% %p2% %p3% %p4% %p5% %p6% %p7% %p8% %p9% > %output% | type %output%

ENDLOCAL
EXIT /B 0

:run_benchmark_all
SETLOCAL
set data_mode=%~1
set variable_update=%~2
set distortions=%~3
for %%m in (%MODELS%) do (
  set batch_size=!BATCH_SIZES[%%m]!
  for /l %%g in (%MIN_NUM_GPU%, 1, %MAX_NUM_GPU%) do (
    for /l %%i in (1, 1, %ITERATIONS%) do (
      CALL :run_benchmark %%m, !batch_size!, %CPU_NAME%, %%g, %%i, %data_mode%, %variable_update%, %distortions%
    )
  )
)
ENDLOCAL
EXIT /B 0

:MAIN
SETLOCAL
for %%m in (%DATA_MODE%) do (
  for %%u in (%VARIABLE_UPDATE%) do (
    for %%d in (true false) do (
      set res=F
      if not "%%m"=="syn" set res=T
      if not "%%d"=="true" set res=T
      if "!res!"=="T" call :run_benchmark_all %%m, %%u, %%d
      
    )
  )
)
ENDLOCAL
EXIT /B %ERRORLEVEL%




