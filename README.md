# Fantasy Hockey Workspace
## Description
Space for using NHL player and team data to improve fantasy hockey performance.  
Required software: R  
Author: Bryan Michalek

## most_valuable_weekly_teams.R
Web scrape a daily-updated table from the Hockey-Reference website containing NHL matchup results (https://www.hockey-reference.com/leagues/NHL_2023_games.html) to create a plot reflecting each team's goal differential in the past 4 games and the relative strength of their upcoming schedule (using team points). The quadrants of the plot correspond to:

- <ins>Lower Left:</ins> On average worse than upcoming opponents and little recent success
- <ins>Upper Left:</ins> On average worse than upcoming opponents but recent success
- <ins>Lower Right:</ins> On average better than upcoming opponents but little recent success
- <ins>Upper Right:</ins> On average better than upcoming opponents and recent success 

Fantasy hockey managers should search for players on the waiver wire on teams located in the upper right corner of the plot. This script can help narrow down the list of players to search through and give an edge to one of two equally skilled free agents.

### Usage
Arguments: week begin date, week end date.  
Example command line usage:
```sh
Rscript most_valuable_weekly_teams.R 2022-01-01 2022-01-07
```
### Example Output
<p align="center">
<img width="650" height="500" alt="image" src="https://user-images.githubusercontent.com/109704770/180845544-c4abe91e-bc54-4698-975c-f0c3b1412a2e.png">  
</p>

## WRITE_skaters_2020_2022.R
Uses many .csv's from NHL.com/stats to build a summary data frame of skaters from the 2020-2021 and 2021-2022 seasons that can be used for future projects. Information at the player/season level includes the following:

- <ins>Characters:</ins> Player
- <ins>Factors:</ins> Season, Team, Shoots (left or right), Pos (position)
- <ins>Numeric:</ins> GP (games played), G (goals), A (assists), P (points), PlusMinus, PIM (penalty minutes), P.PG (points/game), EVG (even strength goals), EVP (even strength points), PPG (power play goals), PPP (power play points), SHG (short handed goals), SHP (short handed points), OTG (overtime goals), GWG (game-winning goals), S (shots), S_Percent (shooting percentage), TOImin.GP ([time-on-ice in minutes]/game), FOW_Percent (faceoff win percentage), Traded_Status, Hits, Hits.60 (hits per 60 min), BkS (blocks), BK.60 (blocks per 60 min), GvA (giveaways), GvA.60 (giveaways per 60 min), TkA (takeaways), TkA.60 (takeaways per 60 min), Fp (yahoo fantasy points), Fp.GP (yahoo fantasy points per game)  

### Usage & Output
Example command line usage:
```sh
Rscript WRITE_skaters_2020_2022.R
```

Produces output titled 'skaters_20_22_combined.csv'

## Roadmap
Projects that are in the works:
- <ins>Rising stars:</ins> Query skaters_20_22_combined.csv to investigate which players have improved the most in terms of Fp.GP between the two seasons. Do these players have anything in common? Do they play the same position? Were they traded to better teams or teams where they play a larger role on the ice? Pay attention to these players in the middle rounds of the next draft after the league's top players have already been selected. A fantasy manager who nails the second half of the draft can gain a substantial edge against the rest of his/her league.
- <ins>More to come!!</ins>
