#install.packages("qqman")
#install.packages("plyr")

library(qqman)
library(plyr)
library(tidyverse)

setwd("PUT DIRECTORY HERE")

data1<-read.table("PUT FILENAME HERE", 
                  header = TRUE, stringsAsFactors = FALSE)

data1<-data1%>%filter(TEST == "PUT COVARIATE OF INTEREST HERE")
data1<-data1 %>% select(CHR, SNP, BP, P)
data1<-as_tibble(data1)
data1

data1[,-2]<-sapply(data1[,-2], as.numeric)
data1<-drop_na(data1)
data1

manhattan(data1, 
          main = "PUT GRAPH TITLE HERE", 
          ylim = c(0, 10), cex = 0.6, 
          annotatePval = 0.00001, annotateTop = FALSE,
          cex.axis = 0.9, col = c("red", "black"), 
          suggestiveline = -log10(1e-05), genomewideline = -log10(5e-08), 
          chrlabs = c(1:22, "X", "Y"))

qq(data1$P, main = "PUT GRAPH TITLE HERE", 
   xlim = c(0, 7), 
   ylim = c(0, 12), pch = 18, col = "blue4", cex = 1.5, las = 1)
