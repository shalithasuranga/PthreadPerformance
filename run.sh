#!/bin/bash


# ----------------------------------------------
# Author - Shalitha Suranga
# ----------------------------------------------

# ---------- Configuration ---------------------
THREADS=( 1 2 4 8 16 )
AVG_TIMES=10
FIXED_MATRIX=512


AVG_TIMES_O=$AVG_TIMES
let AVG_TIMES=AVG_TIMES-1
# commands for each program compilation and its output files

programs=( 'gcc MatrixCPUPthread.c -pthread -o output/out' )

outputfiles=('output/datafile0.dat')

echo ""
echo "This script will create ${#outputfiles[@]} datafile(s)"
echo ""
	

# Remove if outputfile exists otherwise create
function createOrEmpty {
	if [ -e $1 ] 
	then
		rm -rf $1
		touch $1
	else
		touch $1
	fi
}

echo "Fixed matrix size is $FIXED_MATRIX"

GRAPHS=($(seq 1 ${#programs[@]}))

for g in "${GRAPHS[@]}"
do
	:

	outputfile="${outputfiles[$g-1]}"
	program="${programs[$g-1]}"

	createOrEmpty $outputfile

	echo ""
	echo "---------- [STAGE 1] generating data for $outputfile ----------"
	echo ""

	for i in "${THREADS[@]}"
	do
		:

		TIMES=($(seq 0 $AVG_TIMES))
		total="0"
		echo "THREADS=$i"
		for j in "${TIMES[@]}"
		do 
			:
			eval $program
			resp=$(./output/out $FIXED_MATRIX $i)
			total=$(bc <<< "scale=10; $total+$resp")
			echo "# iteration=$j T=$resp"
		done
		avg=$(bc <<< "scale=10; $total/${#TIMES[@]}")
		printf "( $i, $avg )\n" >> $outputfile
		echo "T avg. = $avg"
	done
	echo "Written data to $outputfile"

done


echo ""
echo "Processing completed. Now executing report.sh"
echo ""

# Save metadata

printf "%s " "${THREADS[@]}" > output/meta_threads.dat
printf "%s " "${AVG_TIMES_O}" > output/meta_avg.dat
printf "%s " "${FIXED_MATRIX}" > output/meta_fixedmatrix.dat

bash report.sh
bash report.sh



