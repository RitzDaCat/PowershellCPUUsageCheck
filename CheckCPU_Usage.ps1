# Set the duration for monitoring (in seconds)
$duration = 30

# Get all processes
$processes = Get-Process

# Create a hashtable to store the metrics for each process
$metrics = @{}

# Initialize the hashtable with process names as keys and empty arrays as values
foreach ($process in $processes) {
    $metrics[$process.ProcessName] = @{
        CpuUsage      = 0
        MemoryUsage   = 0
        DiskReadBytes = 0
        DiskWriteBytes = 0
    }
}

# Monitor resource usage for the specified duration
$endTime = (Get-Date).AddSeconds($duration)
while ((Get-Date) -lt $endTime) {
    # Get the resource usage for each process
    foreach ($process in $processes) {
        $cpu = $process.CPU
        $memory = $process.WorkingSet64
        $diskRead = $process.IO.ReadBytes
        $diskWrite = $process.IO.WriteBytes

        $metrics[$process.ProcessName].CpuUsage += $cpu
        $metrics[$process.ProcessName].MemoryUsage += $memory
        $metrics[$process.ProcessName].DiskReadBytes += $diskRead
        $metrics[$process.ProcessName].DiskWriteBytes += $diskWrite
    }
    
    # Wait for 1 second before the next iteration
    Start-Sleep -Seconds 1
}

# Display the results
$results = foreach ($processName in $metrics.Keys) {
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        $threadCount = $process.Threads.Count
    } else {
        $threadCount = 0
    }
    
    [PSCustomObject]@{
        ProcessName    = $processName
        ThreadCount    = $threadCount
        CpuUsage       = $metrics[$processName].CpuUsage
        MemoryUsage    = $metrics[$processName].MemoryUsage
        DiskReadBytes  = $metrics[$processName].DiskReadBytes
        DiskWriteBytes = $metrics[$processName].DiskWriteBytes
    }
}

$results | Sort-Object -Property CpuUsage -Descending | Format-Table -AutoSize
