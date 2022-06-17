set -e
export SIMLEN=10000
export TRACEFILE=$PWD/out.trace
. ../../../cellift-meta/env.sh
benchmarks=$CELLIFT_META_ROOT/benchmarks/out/boom/bin/
( cd $CELLIFT_META_ROOT/benchmarks && bash build-benchmarks.sh boom )
bin=$benchmarks/median.riscv
# XXX probably need different RAM/ROM ELFS
export SIMROMELF=$bin
export SIMSRAMELF=$bin
if [ ! -f $bin ]
then
    echo Benchmarks failed to build.
    exit 1
fi
make run_vanilla_trace
make run_vanilla_notrace
make run_cellift_trace
make run_cellift_notrace
