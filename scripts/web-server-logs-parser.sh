#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "## ERROR: No log file is provided. Please provide a log file."
    exit 1
fi

# Initialize variables
total_requests=0
total_data=0
declare -A resource_counts
declare -A host_counts
status_1xx=0
status_2xx=0
status_3xx=0
status_4xx=0
status_5xx=0

# Read log file line by line
while IFS= read -r line; do
    # Parse line using awk
    request=$(echo "$line" | awk '{print $7}')
    status=$(echo "$line" | awk '{print $9}')
    host=$(echo "$line" | awk '{print $1}')

    # Check if parsing successful, if not, skip line
    if [ -z "$request" ] || [ -z "$status" ] || [ -z "$host" ]; then
        continue
    fi

    # Increment total requests count
    ((total_requests++))

    # Calculate total data transmitted
    data=$(echo "$line" | awk '{print $10}')
    
    # Check if data is a number
    if [[ ! $data =~ ^[0-9]+$ ]]; then
        continue
    fi
    
    ((total_data += data))

    # Count status codes
    case $status in
        1*)
            ((status_1xx++))
            ;;
        2*)
            ((status_2xx++))
            ;;
        3*)
            ((status_3xx++))
            ;;
        4*)
            ((status_4xx++))
            ;;
        5*)
            ((status_5xx++))
            ;;
    esac

    # Count resource requests
    if [ -n "${resource_counts[$request]}" ]; then
        ((resource_counts[$request]++))
    else
        resource_counts[$request]=1
    fi

    # Count host requests
    if [ -n "${host_counts[$host]}" ]; then
        ((host_counts[$host]++))
    else
        host_counts[$host]=1
    fi

done < "$1"

# Calculate percentages
total_size_gb=$(echo "scale=2; $total_data / (1024 * 1024 * 1024)" | bc)
total_size_gb=$(printf "%.2f" "$total_size_gb")

# Function to calculate percentage
calculate_percentage() {
    local part=$1
    local total=$2
    local percentage=$(echo "scale=10; $part / $total * 100" | bc)
    printf "%.10f" "$percentage"
}

# Print statistics
echo "Total Requests: $total_requests"
echo "Total Data transmitted: $total_size_gb GiB"

# Find most requested resource
most_requested_resource=""
most_requests=0
for resource in "${!resource_counts[@]}"; do
    if (( ${resource_counts[$resource]} > most_requests )); then
        most_requested_resource=$resource
        most_requests=${resource_counts[$resource]}
    fi
done

most_requests_percentage=$(calculate_percentage "$most_requests" "$total_requests")
echo "Most requested resource: $most_requested_resource"
echo "Total requests for $most_requested_resource: $most_requests"
echo "Percentage of requests for $most_requested_resource: $most_requests_percentage"

# Find remote host with most requests
most_requested_host=""
most_host_requests=0
for host in "${!host_counts[@]}"; do
    if (( ${host_counts[$host]} > most_host_requests )); then
        most_requested_host=$host
        most_host_requests=${host_counts[$host]}
    fi
done

most_host_requests_percentage=$(calculate_percentage "$most_host_requests" "$total_requests")
echo "Remote host with the most requests: $most_requested_host"
echo "Total requests from $most_requested_host: $most_host_requests"
echo "Percentage of requests from $most_requested_host: $most_host_requests_percentage"

# Print status code percentages
status_1xx_percentage=$(calculate_percentage "$status_1xx" "$total_requests")
status_2xx_percentage=$(calculate_percentage "$status_2xx" "$total_requests")
status_3xx_percentage=$(calculate_percentage "$status_3xx" "$total_requests")
status_4xx_percentage=$(calculate_percentage "$status_4xx" "$total_requests")
status_5xx_percentage=$(calculate_percentage "$status_5xx" "$total_requests")

echo "Percentage of 1xx requests: $status_1xx_percentage"
echo "Percentage of 2xx requests: $status_2xx_percentage"
echo "Percentage of 3xx requests: $status_3xx_percentage"
echo "Percentage of 4xx requests: $status_4xx_percentage"
echo "Percentage of 5xx requests: $status_5xx_percentage"
