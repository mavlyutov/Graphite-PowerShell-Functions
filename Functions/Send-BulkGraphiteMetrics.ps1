function Send-BulkGraphiteMetrics
{
<#
    .Synopsis
        Sends several Graphite Metrics to a Carbon server with one request. Bulk requests save a lot of resources for Graphite server.

    .Description
        This function takes hashtable (MetricPath => MetricValue) and Unix timestamp and sends them to a Graphite server.

    .Parameter CarbonServer
        The Carbon server IP or address.

    .Parameter CarbonServerPort
        The Carbon server port. Default is 2003.

    .Parameter Metrics
        Hashtable (MetricPath => MetricValue).

    .Example
        Send-BulkGraphiteMetrics -CarbonServer myserver.local -CarbonServerPort 2003 -Metrics @{"houston.servers.webserver01.cpu.processortime" = 54; "houston.servers.webserver02.cpu.processortime" = 43} -UnixTime 1391141202
        This sends the houston.servers.webserver0*.cpu.processortime metrics to the specified carbon server.

    .Example
        Send-BulkGraphiteMetrics -CarbonServer myserver.local -CarbonServerPort 2003 -Metrics @{"houston.servers.webserver01.cpu.processortime" = 54; "houston.servers.webserver02.cpu.processortime" = 43} -DateTime (Get-Date)
        This sends the houston.servers.webserver0*.cpu.processortime metrics to the specified carbon server.

    .Notes
        NAME:      Send-BulkGraphiteMetrics
        AUTHOR:    Alexey Kirpichnikov

#>
    param
    (
        [CmdletBinding(DefaultParametersetName = 'Date Object')]
        [parameter(Mandatory = $true)]
        [string]$CarbonServers,

        [parameter(Mandatory = $true)]
        [hashtable]$Metrics,

        # Will Display what will be sent to Graphite but not actually send it
        [Parameter(Mandatory = $false)]
        [switch]$TestMode,

        # Sends the metrics over UDP instead of TCP
        [Parameter(Mandatory = $false)]
        [switch]$UDP
    )

    # Create Send-To-Graphite Metric
    [string[]]$metricStrings = @()
    foreach ($metric in $Metrics.Keys)
    {
        $metricStrings += $metric + " " + $Metrics[$metric].value + " " + $Metrics[$metric].timestamp
        Write-Verbose ("Metric Received: " + $metricStrings[-1])
    }

    $sendMetricsParams = @{
        "CarbonServers" = $CarbonServers
        "Metrics" = $metricStrings
        "IsUdp" = $UDP
        "TestMode" = $TestMode
    }

    SendMetrics @sendMetricsParams
}