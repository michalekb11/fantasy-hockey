# FANTASY HOCKEY TEAM EVALUATION (WEEK BY WEEK)

# Here, we will web scrape an up-to-date NHL schedule and use this to generate a graphic describing 
# what teams it would be optimal to acquire players from in fantasy hockey for any given upcoming week.
# More specifically, we are interested in things such as:
  # 1. How many games does each team play in the upcoming week? More games = More fantasy points.
  # 2. How has each team performed recently? We will use their goal differential from the past few games to evaluate this.
  # 3. What is the strength of their upcoming schedule? We will use the difference between the team's points and the 
     # average points of their opponents for that week.

#----------------------------------------------------------------------------------
# USER INPUT
  # Specify directory you want output file saved in
setwd("~/Documents/Fantasy_Hockey/most_valuable_teams")
  # The date range desired (the dates of the weekly match up)... Comes from command line arguments (ex: "2021-12-31 2022-1-6")
args <- commandArgs(trailingOnly = TRUE)
weekStart <- as.Date(args[1])
weekEnd <- as.Date(args[2])

#----------------------------------------------------------------------------------
# Load data + libraries required
  # libraries
library(dplyr)
library(ggplot2)
library(ggrepel)
library(rvest)
library(RColorBrewer)

  # Web scrape schedule from hockey reference
url <- "https://www.hockey-reference.com/leagues/NHL_2023_games.html"

sched <- read_html(url) %>% 
  html_node("table") %>% 
  html_table() %>% 
  na_if("")

  # Clean up the data frame
colnames(sched) <- c("Date", "Visitor", "v.Goals", "Home", "h.Goals", "Status", "Attendance", "LOG", "Notes")
sched$Date <- as.Date(sched$Date)

sched[!is.na(sched$v.Goals) & !is.na(sched$h.Goals) & !(sched$Status %in% "OT"), "Status"] <- "Regulation"
sched[is.na(sched$Status), "Status"] <- "Scheduled"

  # Create different forms of date ranges we need later
dateRange <- seq(weekStart, weekEnd, by = "days")
dateRange.written <- paste(format(weekStart, format = "%B %d"), format(weekEnd, format = "%B %d"), sep = " - ")
dateRange.condensed <- paste(format(weekStart, format = "%m%d"), format(weekEnd, format = "%m%d"), sep = "_")
#----------------------------------------------------------------------------------
# Weekly number of games
  # figure out what teams play the most games home and away
weekSched <- sched[sched$Date %in% dateRange, ]
visitorGames <- count(weekSched, Visitor)
homeGames <- count(weekSched, Home)

  # merge home and away
totalGames <- merge(homeGames, visitorGames, by.x = "Home", by.y = "Visitor", all = T)
colnames(totalGames) <- c("Team", "Home", "Away")
totalGames[is.na(totalGames)] <- 0
totalGames["Total"] <- rowSums(totalGames[, c("Home", "Away")])

  # classify total number of games as <=2, 3, or >=4
totalGames[totalGames$Total <= 2, "Many.Games"] <- "<= 2"
totalGames[totalGames$Total == 3, "Many.Games"] <- "3"
totalGames[totalGames$Total >= 4, "Many.Games"] <- ">= 4"
totalGames$Many.Games <- factor(totalGames$Many.Games, levels = c("<= 2", "3", ">= 4"), ordered = T)

  # sort for easy visual
totalGames <- totalGames %>% arrange(desc(Total), desc(Home), desc(Away))

#----------------------------------------------------------------------------------
# Team standings, total points
  # remove games that haven't been played, add winner column
finished.games <- sched[!(sched$Status %in% c("Scheduled", "Postponed")), ]
finished.games["Winner"] <- ifelse(finished.games$v.Goals > finished.games$h.Goals, "Visitor", "Home")

  # calculate teams points
team.list <- unique(c(sched$Visitor, sched$Home)) %>% sort()
team.points <- rep(0, 32)
names(team.points) <- team.list

for(i in 1:nrow(finished.games)){
  winner.status <- finished.games$Winner[i]
  winner.name <- as.character(finished.games[i, winner.status])
  team.points[winner.name] <- team.points[winner.name] + 2
  
  if(finished.games$Status[i] != "Regulation"){
    OT.loser.status <- ifelse(winner.status == "Home", "Visitor", "Home")
    OT.loser.name <- as.character(finished.games[i, OT.loser.status])
    team.points[OT.loser.name] <- team.points[OT.loser.name] + 1
  }
}

  # create data frame for merging later
team.points <- data.frame(Team = names(team.points), Points = team.points, row.names = NULL)
team.points <- team.points %>% arrange(desc(Points))

#----------------------------------------------------------------------------------
# Strength of schedule for upcoming week
  # find list of opponents for each team
opponents <- vector("list", 32)
names(opponents) <- team.list

for(i in 1:nrow(weekSched)){
  opponents[[weekSched$Home[i]]] <- opponents[[weekSched$Home[i]]] %>% append(weekSched$Visitor[i])
  opponents[[weekSched$Visitor[i]]] <- opponents[[weekSched$Visitor[i]]] %>% append(weekSched$Home[i])
}

  # calculate strength of schedule for each team (mean of opponents team points as a measure)
strength <- rep(0, 32)
names(strength) <- team.list

for(team in team.list){
  points <- mean(team.points[team.points$Team %in% opponents[[team]], "Points"]) %>% round(2)
  strength[team] <- points
}

  # create data frame for merging with their own strength, calculate differential between the two
strength <- data.frame(Team = names(strength), Strength.of.Schedule = strength, row.names = NULL)
strength <- merge(team.points, strength, by = "Team")
strength["Strength.Differential"] <- strength$Points - strength$Strength

#----------------------------------------------------------------------------------
# Goal differential in past 4 games
past.N.games <- 4
goal.diff <- rep(NA, 32)
names(goal.diff) <- team.list

  # grab last 4 games for each & calculate goal differential
for(team in team.list){
  goals.for <- 0
  goals.against <- 0
  
  temp.df  <- finished.games[finished.games$Visitor == team | finished.games$Home == team, ] %>% arrange(Date)
  temp.df <- tail(temp.df, past.N.games)
  
  if(nrow(temp.df) == 0){
    goal.diff[team] <- 0
    next
  }
  
  for(i in 1:nrow(temp.df)){
    if(temp.df$Visitor[i] == team){
      goals.for <- goals.for + as.integer(temp.df[i, "v.Goals"])
      goals.against <- goals.against + as.integer(temp.df[i, "h.Goals"])
    }else{
      goals.for  <- goals.for + as.integer(temp.df[i, "h.Goals"])
      goals.against <- goals.against + as.integer(temp.df[i, "v.Goals"])
    }
  }
  
  goal.diff[team] <- goals.for - goals.against
}

  # create data frame for merging later
goal.diff <- data.frame(Team = names(goal.diff), Goal.Differential = goal.diff, row.names = NULL)

#----------------------------------------------------------------------------------
# Make plot or table comparing displaying strength differential, number of games, and goal differential
# in the past few games
# Ideally, want to pick up players from teams with large strength differentials, large # of games, and 
# large goal differentials

  # merge total number of games with strength of schedule info
team.master.info <- merge(totalGames, strength, by = "Team")
team.master.info <- merge(team.master.info, goal.diff, by = "Team")

  # make plot of recent goal differential (y) vs strength of schedule (x) 
  # color the plot based on the number of games the team plays in the upcoming date range
#colors <- c("1" = "purple2", "2" = "red", "3" = "darkblue", "4" = "darkgreen", "5" = "cyan2")
colors <- brewer.pal(4, "RdYlGn")
names(colors) <- c("1", "2", "3", "4")
colors["3"] <- "black"

plot <- team.master.info %>% ggplot(aes(x = Strength.Differential, y = Goal.Differential, color = as.factor(Total))) + 
  geom_point() +
  geom_text_repel(aes(label = Team), size = 3.5) +
  geom_hline(yintercept = 0, color = "gray70", linetype = "dashed") +
  geom_vline(xintercept = 0, color = "gray70", linetype = "dashed") +
  theme_bw() +
  labs(x = "Strength differential of upcoming schedule (points)", 
       y = "Goal differential (past 4 games)", 
       title = paste("Most valuable teams:", dateRange.written), 
       color = "Number of upcoming games"
       ) +
  #scale_color_brewer(type = "seq", palette = "YlGn") +
  scale_color_manual(values = colors) + 
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title.x = element_text(size=14, face="bold"),    
    axis.title.y = element_text(size=14, face="bold"),    
    axis.text.x = element_text(size=12, face="bold"), 
    axis.text.y = element_text(size=12, face="bold"), 
    legend.text = element_text(size = 10, face = "bold"),
    legend.title = element_text(size = 12, face = "bold"),
    panel.border = element_rect(size = 1)
    )
  # save plot
ggsave(filename = paste0("most_valuable_teams_", dateRange.condensed, ".png"), plot = plot, device = "png", width = 11, height = 8)
