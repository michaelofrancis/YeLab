#Mike Francis, 1-24-2021
#This is an example script in R for how to *efficiently* generate a simple descriptive table summarizing statistics
#For both quantitative and categorical UK Biobank traits.
#Particularly of interest is the use of dplyr/tidyverse functions group_by and summarise_all in combination with 
#the funs function calls command.
#Before realizing this combination of functions I was tempted to write a cumbersome double "for" loop to do the same
#task in 20+ lines of code that here is done in far less code.


###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#Load packages
###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

library(plyr)
library(dplyr)
library(tidyverse)

#Load a function I wrote (found here: https://github.com/michaelofrancis/Functions/blob/master/manyColsToDummy.R)
source('../manyColsToDummy.R')

#Calling this script loads the bd UK Biobank dataset. (Found here: /project/kylab/lab_shared/UKB/pheno/ukb34137_loaddata.r)
source('../ukb34137_loaddata.r') 


#Load additional UK Biobank variables
bd_add<-read.table("../UKBpheno/pheno/updated_42606/ukb42606.tab",
                   header=TRUE, sep="\t")

bd_add<-as_tibble(bd_add)

###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#Get UK Biobank data of interest
###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#Combine both UK Biobank datasets for easier column selection
bdkeepfull<-inner_join(bd, bd_add, by=c("f.eid", "f.22000.0.0"))
bdkeepfull<-as_tibble(bdkeepfull)


#Select columns of interest
new<-bdkeepfull%>%select(f.eid, f.31.0.0, f.21003.0.0, f.21000.0.0, 
                        f.21001.0.0,
                        f.4080.0.0, f.4079.0.0, 
                        f.30750.0.0, f.30780.0.0, f.30760.0.0,
                        f.30870.0.0, f.30690.0.0,
                        f.22001.0.0 
                        )
#Name columns of interest
colnames(new)<-c("IID", "Sex", "Age",  "Race",                   
                 "BMI",
                 "SBP", "DBP",
                 "HbA1c", "LDL", "HDL",
                 "TAGs", "TC",
                 "Genetic_Sex"
                  )

#Sex is easier to deal with as a numerical value
new$Sex<-as.numeric(mapvalues(as.character(new$Sex), 
                   c("Male", "Female"), c(0,1)))

new$Genetic_Sex<-as.numeric(mapvalues(as.character(new$Genetic_Sex), 
                   c("Male", "Female"), c(0,1)))

###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#Add ICD-10 diagnosis columns (protocol found in manyColsToDummy.R example)
###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

diagcols<-sprintf("f.41270.0.%s", 0:212)
searchterms<-c("I10", 
               "I15",
               "E10",
               "E11",
               "E12",
               "E13",
               "E14")
names(searchterms)<-c("Essential_primary_hypertension", 
                      "Secondary_hypertension",
                      "Insulin_dependent_diabetes_mellitus",
                      "Non_insulin_dependent_diabetes_mellitus",
                      "Malnutrition_related_diabetes_mellitus",
                      "Other_specified_diabetes_mellitus",
                      "Unspecified_diabetes_mellitus"
                      )

manyColsToDummy(searchterms, bd[,diagcols], "diag_output")
colnames(diag_output)<-names(searchterms)

diag_output$IID<-bd$f.eid
diag_output<-as_tibble(diag_output)


new<-left_join(new, diag_output, by= "IID")
new

###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Task: For each race, generate a table summarizing statistics for each variable 
# such as mean, sd, median, and IQR
###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


levels(new$Race) #Looking at how many races there are

new<-new[(!is.na(new$Race)),] #remove 898 missing race (and probably more info)

###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
##Get summary stats
###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

quantpheno<-c("Age",  "BMI",
              "SBP", "DBP", "HbA1c", "LDL", "HDL",
              "TAGs", "TC")
    
    
catpheno<-c("Sex", "Genetic_Sex", "Essential_primary_hypertension", 
            "Secondary_hypertension",
            "Insulin_dependent_diabetes_mellitus",
            "Non_insulin_dependent_diabetes_mellitus",
            "Malnutrition_related_diabetes_mellitus",
            "Other_specified_diabetes_mellitus",
            "Unspecified_diabetes_mellitus")


#Generate table for quantitative phenotypes
quantitative<-as.data.frame(
new%>%select("Race", quantpheno)%>%
    group_by(Race)%>%summarise_all( 
        funs(n = sum(!is.na(.)), 
             min(., na.rm = TRUE),
             max(., na.rm = TRUE),
             mean(., na.rm = TRUE),
             sd(., na.rm = TRUE),
             median(., na.rm = TRUE),
             IQR(., na.rm = TRUE),
             ))
)

#Generate table for categorical phenotypes
categorical<-as.data.frame(
    new%>%select("Race", catpheno)%>%
        group_by(Race)%>%summarise_all( 
            funs(n = sum(!is.na(.)), 
                 percent = (100*mean(., na.rm = TRUE))

            ))
)

###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#Save results to file
###-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

write.csv(quantitative, "quantitative_UKB_byRace.csv")
write.csv(categorical, "categorical_UKB_byRace.csv")
