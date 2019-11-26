library(tidyverse)
setwd("/Users/yelab/Documents/R_files/Seurat_ACTINN/")

#Load in data
ACTINN_raw<-read.delim("predicted_label.txt", header = TRUE, 
           stringsAsFactors = FALSE, sep='\t')
ACTINN<-as_tibble(ACTINN_raw)

Seurat_names_raw<-read.delim("demo_cluster_names.csv",
                                stringsAsFactors = FALSE)

#Tidy data
Seurat_names_raw$names<-Seurat_names_raw$value.names
colnames(Seurat_names)<- c("value", "names")
head(Seurat_names_raw)
length(unique(Seurat_names_raw$names))

Seurat_names<-as_tibble(Seurat_names_raw)
Seurat_namesa<-do.call(rbind, strsplit(Seurat_names$value, ' (?=[^ ]+$)', perl=TRUE))
Seurat_namesa<-as_tibble(Seurat_namesa)
Seurat_namesa<-Seurat_namesa%>%select(V2, V1)
colnames(Seurat_namesa)<- c("cellname", "celltype")

ACTINN$cellname<-str_split(ACTINN$cellname, "-", simplify=TRUE)[,1]

#Merge data
merged<-left_join(Seurat_namesa, ACTINN, by="cellname")
colnames(merged)<-c("cellname", "celltype_Seurat", "celltype_ACTINN")
head(as.data.frame(merged), 25)
merged$celltype_ACTINN[merged$celltype_ACTINN == "B cell"]<-"B"
merged$celltype_ACTINN[merged$celltype_ACTINN == "NK cell"]<-"NK"

#Aggregate combination counts
agg<-count(merged, celltype_Seurat, celltype_ACTINN)

#Plot results
png("Seurat_vs_ACTINN.png")
p1 <- ggplot(agg) +
    geom_col(aes(x = celltype_Seurat, y = n, fill = celltype_ACTINN))+
    scale_fill_manual(values=c("#00BFFF", "orange", 
                               "#228B22", "purple", "#DC143C"))+
    theme(axis.text.x = element_text(angle=90))
p1
dev.off()
