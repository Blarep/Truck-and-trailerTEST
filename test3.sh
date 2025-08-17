#!/bin/bash

# Define the directory containing the instance files
INSTANCE_DIR="instancesMedium"

# Define the output file name
OUTPUT_FILE="results200It-1500iniciales-17-8.txt"

# Number of iterations per run
ITERATIONS=200

# Number of runs per solution
NUM_RUNS=1500

# Solution Folder
SOLUTION_FOLDER="instances200-1500-17-8"

# Number of parallel groups (hilos)
NUM_GROUPS=15

# Remove the existing output file
rm -f "$OUTPUT_FILE"

# Define solution types
SOLUTION_TYPES=("SolutionB" "SolutionC")

# Create the solution folder if it does not exist
mkdir -p "$SOLUTION_FOLDER"

# List all instance files
INSTANCE_FILES=($INSTANCE_DIR/*.dat)
TOTAL_INSTANCES=${#INSTANCE_FILES[@]}

# Define a function for processing a subset of instances
run_group() {
    local group_id=$1
    local num_groups=$2
    for ((i=group_id; i<TOTAL_INSTANCES; i+=num_groups)); do
        instance_file="${INSTANCE_FILES[$i]}"
        instance_name=$(basename "$instance_file" .dat)

        # Create instance directory
        instance_dir="$SOLUTION_FOLDER/$instance_name"
        mkdir -p "$instance_dir"

        for solution_type in "${SOLUTION_TYPES[@]}"; do
            # Create solution type directory inside instance directory
            solution_dir="$instance_dir/$solution_type"
            mkdir -p "$solution_dir"

            for ((run=1; run<=NUM_RUNS; run++)); do
                current_seed=$((run * 1000000))
                # Run the C++ program with the instance file as an argument
                echo "Running instance: $instance_name with $solution_type, run $run, seed $current_seed"
                execution_output=$("./$solution_type" "$instance_file" $ITERATIONS $solution_type $run $SOLUTION_FOLDER $current_seed)

                # Extract the execution time and total distance from the execution output
                execution_time=$(echo "$execution_output" | grep -oP 'Execution time:\K\d+')
                total_distance=$(echo "$execution_output" | grep -oP 'Total distance:\K\d+\.\d+')

                # Export the results to the output file
                echo "Instance: $instance_name, Solution: $solution_type, Run: $run, Seed: $current_seed, Execution time: $execution_time ms, Total distance: $total_distance" >> "$OUTPUT_FILE"
            done
        done
    done
}

# Run parallel groups
for ((group_id=0; group_id<NUM_GROUPS; group_id++)); do
    run_group $group_id $NUM_GROUPS &
done

# Wait for all background processes to finish
wait

echo "Results exported to $OUTPUT_FILE"
