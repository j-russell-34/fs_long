library(tidyverse)
library(dplyr)
library(purrr)
library(glue)

in_dir <- "/Users/jasonrussell/Documents/INPUTS/fslong_A002"
out_dir <- "/Users/jasonrussell/Documents/OUTPUTS/fslong_A002"

#import qdec and sclimbic data
qdec <- read.table(glue("{out_dir}/long.qdec.table.dat"), header = TRUE)
sclimbic <- read.csv(glue("{out_dir}/sclimbic_vols.csv"))
centiloid <- read.csv(glue("{in_dir}/ABC_DS_centiloid_test.csv"))
abeta_chron <- read.csv(glue("{in_dir}/est_AB+_chron.csv"))

#add event to subject id in centiloid table and sclimbiv
centiloid$fsid <- glue("{as.character(centiloid$subject_label)}_e{as.character(centiloid$event_sequence)}")
sclimbic$fsid <- glue("{as.character(sclimbic$subject)}_e{as.character(sclimbic$event)}")


#set up linear mixed effects models
library(lme4)
library(lmerTest)
#library(sjPlot)

#combine dataframes based on subject_id/event code
data <- merge(qdec, sclimbic, by="fsid")
data$basal_forebrain <- 
  (data$left_basal_forebrain + data$right_basal_forebrain)/2
data <- merge(data, centiloid, by="fsid")
data <- merge(data, abeta_chron, by.x=c('fsid.base', 'age'), by.y=c('subid', 'age'))


model_age <- lmer(
  basal_forebrain ~ years * age + eTIV + (1 | fsid.base),
  data = data
)

summary(model_age)

model_centiloid <- lmer(
  basal_forebrain ~ years * centiloid_value + eTIV + age + (1 | fsid.base),
  data = data
)

summary(model_centiloid)

model_abeta_chron <- lmer(
  basal_forebrain ~ years * estdtt0 + eTIV + age + (1 | fsid.base),
  data = data
)

summary(model_abeta_chron)

#plot graph x-axis age, y-axis basal_forebrain volume
# Plot basal forebrain volume over time by age

data$predicted_age <- predict(model_age)

ggplot(data, aes(x = age, y = basal_forebrain/eTIV, color = as.factor(fsid.base))) +
  geom_point() +
  geom_line(aes(group = fsid.base)) +
  #geom_line(aes(y = predicted_age)) +
  labs(title = "Effect of Age on Basal Forebrain Volume Change", 
       x = "Age", 
       y = "Basal Forebrain Volume/TIV") +
  theme_minimal() +
  theme(legend.position = "none")

data$predicted_centiloid <- predict(model_centiloid)

ggplot(data, aes(x = centiloid_value, y = basal_forebrain/eTIV, color = as.factor(fsid.base))) +
  geom_point() +
  geom_line(aes(group = fsid.base)) +
  #geom_line(aes(y = predicted_centiloid)) +
  labs(title = "Effect of Amyloid Accumulation on Basal Forebrain Volume Change", 
       x = "Centiloid", 
       y = "Basal Forebrain Volume/TIV") +
  theme_minimal() +
  theme(legend.position = "none")

data$predicted_abeta_chron <- predict(model_abeta_chron)

ggplot(data, aes(x = estdtt0, y = basal_forebrain/eTIV, color = as.factor(fsid.base))) +
  geom_point() +
  geom_line(aes(group = fsid.base)) +
  #geom_line(aes(y = predicted_abeta_chron)) +
  labs(title = "Effect of Amyloid Beta Chronicity on Basal Forebrain Volume Change", 
       x = "Amyloid Beta Chronicity", 
       y = "Basal Forebrain Volume/TIV") +
  theme_minimal() +
  theme(legend.position = "none")

