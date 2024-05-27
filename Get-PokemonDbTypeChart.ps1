using assembly HtmlAgilityPack.dll
using namespace HtmlAgilityPack
Set-StrictMode -Version Latest

$web = [HtmlWeb]::new()
$doc = $web.Load('https://pokemondb.net/type')
$table = $table = $doc.DocumentNode.SelectSingleNode('//table[@class="type-table"]')
$defense = $table.Element('thead').Element('tr').Elements('th').Element('a') | 
    Where-Object { $_ } | ForEach-Object {$_.Attributes['class'].Value.Split(' ')[1].Split('-')[1]}
$attack = $table.Element('tbody').Elements('tr').Element('th').Element('a') |
    Where-Object { $_ } | ForEach-Object {$_.Attributes['class'].Value.Split(' ')[1].Split('-')[1]}

$chart = [ordered]@{}
$defense | ForEach-Object { $chart[$_] = [ordered]@{} }

$a = 0
$table.Element('tbody').Elements('tr') | ForEach-Object {
    $attackType = $attack[$a++]
    $d = 0
    $_.Elements('td') | ForEach-Object {
        $chart[($defense[$d++])][$attackType] = ([int]($_.Attributes['class'].Value.Split('-')[-1]))/100.0
    }
}
$chart|ConvertTo-Json -Depth 3|Out-File TypeChart.json