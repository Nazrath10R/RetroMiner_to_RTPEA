
setwd("~/Dropbox/PhD/retroelement_expression_atlas/data/sizes")

files <- list.files(path=".", pattern = ".+_size.txt")


size_matrix <- matrix(NA, 1, 2)
size_matrix <- as.data.frame(size_matrix)
colnames(size_matrix) <- c("PXD", "size")


for(x in 1:length(files)) {
  
  pxd <- unlist(strsplit(files[x], split = "_"))[1]
  
  print(paste(x, pxd))
  
  file <- read.table(files[x])
  size <- sum(as.numeric(unique(file$V1)))/1048576
  
  info <- c(pxd,size)
  
  size_matrix[x,] <- info

  
}

size_matrix$size <- round(as.numeric(size_matrix$size), 3)

size_matrix

write.table(size_matrix, "sizes_matrix.txt", row.names = FALSE , sep = "\t")

n <- read.table("../sizes/sizes_matrix.txt", header = TRUE)
sum(n$size)/1024

# read.table("~/Dropbox/PhD/retroelement_expression_atlas/data/sizes/sizes_matrix.txt", header = TRUE)



#### Mining numbers


setwd("~/Dropbox/PhD/retroelement_expression_atlas/data/results/new")

files <- list.files(path=".", pattern = ".+jSON")
size_matrix <- read.table("~/Dropbox/PhD/retroelement_expression_atlas/data/sizes/sizes_matrix.txt", header = TRUE)

length(files)
sum(size_matrix$size)/1024


library("jsonlite")


json_template <- fromJSON("./visualise_example.json")
















