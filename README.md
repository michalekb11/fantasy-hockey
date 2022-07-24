# Fantasy Hockey Workspace
## Description
Space for using NHL player and team data to improve fantasy hockey performance.  
Required software: R
Author: Bryan Michalek

## most_valuable_teams.R
Uses a daily updated .csv of NHL matchup results to create a plot reflecting each teams goal differential in the past 4 games and the relative strength of their upcoming schedule (using team points). The corners of the plot correspond to:

- Lower Left: On average worse than upcoming opponents and little recent success
- Upper Left: On average worse than upcoming opponents but recent success
- Lower Right: On average better than upcoming opponents and little recent success
- Upper Right: On average better than upcoming opponents and recent success 

Fantasy hockey managers should search for players on the waiver wire on teams located in the upper right corner of the plot. This script can help narrow down the list of players to search through and give an edge to one of two equally skilled free agents.

### Usage
Arguments: week begin date, week end date.  
Example command line usage:
```sh
Rscript most_valuable_teams.R 2022-01-01 2022-01-07
```
### Example Output


## Roadmap
Projects that are in the works:
- x
