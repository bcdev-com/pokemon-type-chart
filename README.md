# Gengar's Type Chart

## TL;DR

This is the build code for [Gengar's Type Chart.](https://typechart.ofholding.ca)

## Backstory

I recently started playing Pokémon with my, now adult, child.  We are playing Scarlet & Violet and it is evolved a long way from the last time I played Pokémon. (Which was the original Red & Blue with this child's older sister in the '90s.)

There are endless type charts available online, but at my age they were hard to read on a phone screen so I decided to make my own.  Like most geek tools, I made it for myself, but I hope others might find it useful.

## Design Notes

I used the extremely detailed [Pokémon Database](https://pokemondb.net/) for the underlying type matchup data.  You'll find the PowerShell code to scrape their type chart into a simple JSON file in ```Get-TypeChart.ps1.```

I manually extracted the SVG outlines from Elginive's [lovely recreations.](https://github.com/Elginive/pokemon-type-icons)  I split each type's icon out into a separate file and wrapped it in transforms to place it back into a 0 0 64 64 viewbox.  These files might be useful for other projects, but all creative credit goes to Elginive.  I didn't touch the path data at all.

```New-HTMLChart.ps1``` uses the JSON from above to drive creation of an HTML file that contains only the structure, with no text, colors, images or presentation.  

The bulk of the work is in the ```style.css```. This, with the SVG image assets, produces a mobile-focused web page.  While it works in a desktop browser, unless your window is tall and narrow it won't be very pleasing.

Finally, the ```-SingleFile``` switch to ```New-HTMLChart.ps1``` embeds the 18 little svg files into the stylesheet and the stylesheet into the HTML, resulting in a single output file.

## Name Choice

I called the tool Gengar's Type Chart for two reasons.  He was my favorite Pokémon back in the Red/Blue days, but also because the 😈 emoji is close enough to serve as a text-mode favicon for a non-artist like me.

-Blake, May 2024