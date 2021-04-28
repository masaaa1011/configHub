Param($type)

function ReadConfig($config_location) {
    return (Import-Csv -Path $config_location -Header Key,Value -Delimiter "=").Where({$null -ne $PSItem.Value})
}
function Apply($config, $dest) {
    $config.ForEach({ 
        $localpath = ConvertLocalDirName($PSItem.Value)
        Robocopy.exe (Join-Path $dest $localpath) $PSItem.Value $PSItem.Key /DCOPY:DAT 
    })
}
function Collect($config, $dest) {
    $config.ForEach({ 
        $localpath = ConvertLocalDirName($PSItem.Value)
        Robocopy.exe $PSItem.Value (Join-Path $dest $localpath) $PSItem.Key /DCOPY:DAT 
    })
}

function ConvertLocalDirName($path) {
    return $path.Replace("\", "_").Replace(":", "_")
}

# ---------- メインスクリプト ----------
$config_location = "./config.ini"
$store = "./configs"
$config = @{}

if($null -eq $type) {
    Write-Host "\-type Apply または \-type Collect を指定してください";
}

$config = ReadConfig($config_location)
$config.ForEach({
        $localpath = ConvertLocalDirName($PSItem.Value)
        if(!(Test-Path (Join-Path $store $localpath)))
        {
            New-Item (Join-Path $store $localpath) -ItemType Directory
        }
    })

Write-Host $type

switch ($type) {
    "Apply" { Apply $config $store }
    "Collect" { Collect $config $store }
    Default {
        Write-Host "\-type Apply または \-type Collect を指定してください"
        exit 
    }
}

# dotnetのバージョンが対応してなかった時のために作成
# function ReadConfig($config_location) {
#     $response = @{}
#     $_config = Import-Csv -Path $config_location -Header Key,Value -Delimiter "="
    
#     foreach($c in $_config) {
#         if($c.Value -ne $null) {
#             $response.Add($c.Key, $c.Value)
#         }
#     }
#     return $response
# }