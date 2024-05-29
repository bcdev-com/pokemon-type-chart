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
    Get-Content $PSScriptRoot\dual.css | ForEach-Object {
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
    "  <link rel='stylesheet' href='dual.css'>"
}
@"
</head>
<body>
"@

function Write-Against($strength, $types) {
    if ($types.Length -gt 0) {
        "      <div class='$strength'>"
        $types | ForEach-Object { "        <a class='$_ move' href='#$_-$_'></a>" }
        "      </div>"
    }
}

$chart = Get-Content -Raw $PSScriptRoot\TypeChart.json | ConvertFrom-Json -AsHashtable
"<main>"
$chart.Keys | ForEach-Object { "  <a class='$_ type' href='#$_'></a>" }
"</main>"

$chart.Keys | ForEach-Object {
    $type = $_
    "<section id='$type' class='$type'>"
    $chart.Keys | ForEach-Object {
        $only = $_ -eq $type ? ' only' : ''
        "  <a class='$_$only type' href='#$type-$_'></a>"
        "  <aside id='$type-$_' class='$_$only'>"
        $attacks = $chart[$type]
        if ($type -eq $_) {
            "    <div class='defending'>"
            Write-Against 'x200' @($attacks.Keys | Where-Object { $attacks[$_] -eq 2 })
            Write-Against 'x50' @($attacks.Keys | Where-Object { $attacks[$_] -eq 0.5 })
            Write-Against 'x0' @($attacks.Keys | Where-Object { $attacks[$_] -eq 0 })
            "    </div>"
            "    <div class='attacking'>"
            Write-Against 'x200' @($chart.GetEnumerator() | Where-Object {$_.Value[$type] -eq 2} | ForEach-Object { $_.Name })
            Write-Against 'x50' @($chart.GetEnumerator() | Where-Object {$_.Value[$type] -eq 0.5} | ForEach-Object { $_.Name })
            Write-Against 'x0' @($chart.GetEnumerator() | Where-Object {$_.Value[$type] -eq 0} | ForEach-Object { $_.Name })
            "    </div>"
        } else {
            $second = $chart[$_]
            "    <div class='defending'>"
            Write-Against 'x400' @($attacks.Keys | Where-Object { ($attacks[$_] * $second[$_]) -eq 4 })
            Write-Against 'x200' @($attacks.Keys | Where-Object { ($attacks[$_] * $second[$_]) -eq 2 })
            Write-Against 'x50' @($attacks.Keys | Where-Object { ($attacks[$_] * $second[$_]) -eq 0.5 })
            Write-Against 'x25' @($attacks.Keys | Where-Object { ($attacks[$_] * $second[$_]) -eq 0.25 })
            Write-Against 'x0' @($attacks.Keys | Where-Object { ($attacks[$_] * $second[$_]) -eq 0 })
            "    </div>"
        }
        "    <a class='reset' href='#'></a>"
        "  </aside>"
    }
    "</section>"
}
@"
</body>
</html>
"@