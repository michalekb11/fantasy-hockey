# Summary of Script: The goal of this script is to use downloaded .csv's from NHL.com/stats from the last two seasons
# (2020-2022) to build a data frame useful for future projects. The final data frame will contain information about
# each NHL player at the player/season level such as games played, points, hits, takeaways, etc.

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Libraries
library(dplyr)

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Read in player stats from folder containing only files from NHl.com/stats online database
  # This is the player season summary page from 2020-2021 and 2021-2022 seasons
setwd("/Users/bryanmichalek/Documents/Fantasy_Hockey/player_data/skaters_2020_2022/")
player_summary_20_22 <- lapply(list.files(getwd()), read.csv) %>% 
  do.call(what = rbind)

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Clean up Data Frame
  # Rename columns
player_summary_20_22 <- player_summary_20_22 %>% rename(Shoots = S.C, PlusMinus = X..., S_Percent = S., TOImin.GP = TOI.GP, FOW_Percent = FOW.)

  # Convert TOI (character) to minutes (numeric)
player_summary_20_22$TOImin.GP <- strsplit(player_summary_20_22$TOImin.GP, ":") %>% lapply(as.double) %>% sapply(function(x) x[1] + x[2]/60) %>% round(2)

  # Add Traded_Status column
player_summary_20_22$Traded_Status <- ifelse(nchar(player_summary_20_22$Team) > 3, 1, 0)

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Read in hits and blocks data
setwd("/Users/bryanmichalek/Documents/Fantasy_Hockey/player_data/skaters_hits_blocks_2020_2022")
miscellaneous_20_22 <- lapply(list.files("/Users/bryanmichalek/Documents/Fantasy_Hockey/player_data/skaters_hits_blocks_2020_2022"), read.csv) %>% 
  do.call(what = rbind)
hits_blocks_gives_takes <- miscellaneous_20_22 %>% select(Player, Season, Team, Hits, Hits.60, BkS, BkS.60, GvA, GvA.60, TkA, TkA.60)

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Join hits/blocks/takeaways/giveaways to the summary data frame
player_final_20_22 <- merge(player_summary_20_22, hits_blocks_gives_takes, by = c("Player", "Season", "Team"), all.x = TRUE)

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Final clean
  # Replace '--' with NA's
player_final_20_22 <- player_final_20_22 %>% lapply(function(x) gsub("--", NA, x)) %>% as.data.frame()

  # Set columns to the correct type
factor_columns <- c("Season", "Team", "Shoots", "Pos")
player_final_20_22[factor_columns] <- player_final_20_22[factor_columns] %>% lapply(factor)

int_columns <- c("GP", "G", "A", "P", "PlusMinus", "PIM", "EVG", "EVP", "PPG", "PPP", "SHG", "SHP", "OTG", "GWG", "S", "Traded_Status", "Hits", "BkS", "GvA", "TkA")
player_final_20_22[int_columns] <- player_final_20_22[int_columns] %>% lapply(as.integer)

double_columns <- c("P.GP", "S_Percent","TOImin.GP", "FOW_Percent", "Hits.60", "BkS.60", "GvA.60", "TkA.60")
player_final_20_22[double_columns] <- player_final_20_22[double_columns] %>% lapply(as.double)

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Add fantasy points columns
player_final_20_22 <- player_final_20_22 %>%  mutate(Fp = 6 * G
                                  + 4 * A
                                  + 2 * PlusMinus
                                  + PPG
                                  + 2 * PPP
                                  + 3 * SHG
                                  + 0.5 * GWG
                                  + 0.9 * S
                                  + 0.5 * Hits
                                  + BkS)

player_final_20_22$Fp.GP <- player_final_20_22$Fp / player_final_20_22$GP
player_final_20_22$Fp.GP <- player_final_20_22$Fp.GP %>% round(2)

#--------------------------------------------------------------------------------------------------------------------------------------------------
# Write final data frame to new .csv file
write.csv(player_final_20_22, file = "/Users/bryanmichalek/Documents/Fantasy_Hockey/player_data/skaters_20_22_combined.csv")