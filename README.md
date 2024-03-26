# Web Server Log Parser

This shell script parses a web server log file with the Combined Log Format and outputs statistics based on the web server logs.

The input log files look something like this:

`216.144.240.130 - - [19/May/2019:03:42:51 +0000] "HEAD /robots.txt HTTP/1.1" 404 208 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"`

`169.248.212.254 - - [19/May/2019:03:35:17 +0000] "GET /image.jpg HTTP/1.1" 200 14327 "http://mail.google.com/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246 Mozilla/5.0"`

### Usage

1. Clone the repository:
```bash
git clone https://github.com/prajwalakhuj/onclusive.git -b master
```
2. Navigate to the script directory:
```bash
cd onclusive/scripts
```
3. Run the script:

- Provide the path to your web server log file as an argument when executing the script.
```bash
./web-server-logs-parser.sh /path/to/your/logfile.log
```

### Script Details
**Input**: The script takes a single argument, which should be the path to the web server log file in the Combined Log Format.

**Output**: It outputs various statistics based on the log data, including total number of requests, total data transmitted, most requested resource, remote host with the most requests, and percentages of each class of HTTP status code (1xx, 2xx, 3xx, 4xx, 5xx).

**Parsing**: The script reads the log file line by line, parses each line using `awk`, and extracts relevant information such as request, status code, and remote host.

**Error Handling**: It handles errors gracefully by skipping lines that cannot be parsed successfully.

**Calculations**: The script calculates total requests, total data transmitted, percentages of each status code class, and identifies the most requested resource and remote host with the most requests.

**Functions**: It defines a function calculate_percentage to calculate percentages.
Dependencies: The script relies on standard UNIX utilities such as `awk` and `bc`.

### Example

```bash
./web-server-logs-parser.sh example.log
```
