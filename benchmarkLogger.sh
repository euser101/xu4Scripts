#!/bin/bash

THREADS=$(nproc)
SEPARATE="\n%s\n%s\n"

checkDependencies() {
	if hash sysbench 2>/dev/null; then
	  printf $SEPARATE ""
	else
	  printf $SEPARATE "Installing Dependencies..."
	  sudo apt-get -y install sysbench
	  checkDependencies
	fi
	
	runBenchmark
}

runBenchmark() {
	#Testing CPU, RAM and Disk
	printf $SEPARATE "Starting Benchmarks..."
	TIME=$(date -d "today" +"%Y%m%d%H%M")
	FILENAME=results-$TIME.log
	sysbench --threads=$THREADS --test=cpu --cpu-max-prime=1000 run >> $FILENAME 2>&1
	sysbench --test=mutex --mutex-num=1 --mutex-locks=50000000 --mutex-loops=1 run >> $FILENAME 2>&1
	sysbench --test=memory --memory-block-size=1M --memory-total-size=5G run >> $FILENAME 2>&1
	dd bs=1M count=256 if=/dev/zero of=test conv=fdatasync >> $FILENAME 2>&1
	rm test
	printResults
}

printResults() {
	printf $SEPARATE "Logged Results into File $FILENAME"
	cat $FILENAME
}

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else
  checkDependencies
fi

