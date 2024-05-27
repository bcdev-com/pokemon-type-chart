param([switch]$SingleFile)
@"
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <title>Gengar's Type Chart</title>
  <!--
  Type Chart data thanks to: https://pokemondb.net/type
  SVG icons thanks to: https://github.com/Elginive/pokemon-type-icons
  -->
  <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>😈</text></svg>">
"@
if ($SingleFile) {
    "  <style>"
    Get-Content $PSScriptRoot\style.css | ForEach-Object {
        if ($_ -match '(?n)--icon: url\(types/(?<type>\w+)\.(?<ext>(png|svg))\)') {
            $dataUri = "data:image/$($matches['ext'] -eq 'svg' ? 'svg+xml' : 'png');base64," + [Convert]::ToBase64String(
                [IO.File]::ReadAllBytes("$PSScriptRoot\types\$($matches['type']).$($matches['ext'])"))
            "    --icon: url($dataUri)"
        } else {
            $_
        }
    }
    "  </style>"
} else {
    "  <link rel='stylesheet' href='style.css'>"
}
@"
</head>
<body>
"@

function Write-Against($strength, $types) {
    if ($types.Length -gt 0) {
        "          <div class='$strength'>"
        $types | ForEach-Object { "            <div class='$_ against'></div>" }
        "          </div>"
    }
}

$chart = Get-Content -Raw $PSScriptRoot\TypeChart.json | ConvertFrom-Json -AsHashtable
$n = 0;
$chart.Keys | ForEach-Object {
    $type = $_
    "  <details name='type' class='$type'>"
    "    <summary></summary>"
    "    <div class='details $($n -gt 8 ? 'top' : 'bottom')'>"
    "      <div class='scrolldetails'>"
    "        <div class='defending'>"
    $attacks = $chart[$type]
    Write-Against 'strong' @($attacks.Keys | Where-Object { $attacks[$_] -eq 2 })
    Write-Against 'weak' @($attacks.Keys | Where-Object { $attacks[$_] -eq 0.5 })
    Write-Against 'nothing' @($attacks.Keys | Where-Object { $attacks[$_] -eq 0 })
    "        </div>"
    "        <div class='attacking'>"
    Write-Against 'strong' @($chart.GetEnumerator() | Where-Object {$_.Value[$type] -eq 2} | ForEach-Object { $_.Name })
    Write-Against 'weak' @($chart.GetEnumerator() | Where-Object {$_.Value[$type] -eq 0.5} | ForEach-Object { $_.Name })
    Write-Against 'nothing' @($chart.GetEnumerator() | Where-Object {$_.Value[$type] -eq 0} | ForEach-Object { $_.Name })
    "        </div>"
    "      </div>"
    "    </div>"
    "  </details>"

    ++$n;
}
@"
</body>
</html>
"@