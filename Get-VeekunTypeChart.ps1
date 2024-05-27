$order = @(
    'normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting', 'poison', 'ground', 
    'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy'
)
$tn = Import-Csv $PSScriptRoot\veekun\types.csv
$te = Import-Csv $PSScriptRoot\veekun\type_efficacy.csv

function Get-Efficacy($defender, $attacker) {
    $did = @($tn | Where-Object identifier -eq $defender)[0].id
    $aid = @($tn | Where-Object identifier -eq $attacker)[0].id
    return ($te | Where-Object {$_.damage_type_id -eq $aid -and $_.target_type_id -eq $did})[0].damage_factor / 100.0
}

$tc = [ordered]@{}
$order | ForEach-Object {
    $defender = $_
    $tc[$defender] = [ordered]@{}
    $order | ForEach-Object {
        $attacker = $_
        $tc[$defender][$attacker] = Get-Efficacy $defender $attacker
    }
}
$tc|ConvertTo-Json -Depth 3