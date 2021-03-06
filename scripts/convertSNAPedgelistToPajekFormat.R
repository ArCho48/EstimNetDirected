##!/usr/bin/Rscript
##
## File:    convertSNAPedgelistToPajekFormat.R
## Author:  Alex Stivala
## Created: October 2018
##
## Read a gzipped edge list 
## from SNAP https://snap.stanford.edu/data/
## and convert to Pajek format
##
## Reference for SNAP collection of data sets:
## 
##@misc{snapnets,
##  author       = {Jure Leskovec and Andrej Krevl},
##  title        = {{SNAP Datasets}: {Stanford} Large Network Dataset Collection},
##  howpublished = {\url{http://snap.stanford.edu/data}},
##  month        = jun,
##  year         = 2014
##}
##
## Usage:
## 
## Rscript convert SNAPedgelistToPajekFormat.R infilename.txt.gz
##
## Output files (WARNING overwritten):
##     infilename.txt
##
##

library(igraph)

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  cat("Usage: convertSNAPedgelistToPajekFormat.R\n")
  quit(save="no")
}
infile <- args[1]
basefilename <- sub("(.+)[.].+", "\\1", basename(infile))
##outfilename <- paste(basefilename, 'txt', sep='.')
outfilename <- basefilename

edgelist <- read.table(gzfile(infile))

uniqueIds <- unique(c(edgelist$V1, edgelist$V2))
numIds <- length(uniqueIds)
cat('number of unique ids is ', numIds, '\n')
cat('min is ', min(uniqueIds), ' max is ', max(uniqueIds), '\n')

## Mostly SNAP data sets seem to be edge lists with nodes numbered from 0
## but sometimes (e.g patent citation network) they are not, and instead
## start from something else (1 in that case) and have many missing numbers.
## If we don't account for that here then the network ends up having all
## those missing node ids as isolates so it is not correct.
if (numIds != max(uniqueIds)+1) {
    cat('Vertices are not numbered 0..N-1, renumbering\n')
    ## use R factors to renumber to 1..N and then subtract 1
    ## (since we add one later for the original case)
    fac <- factor(uniqueIds)
    edgelist$V1 <- as.integer(factor(edgelist$V1, levels = levels(fac)))
    edgelist$V2 <- as.integer(factor(edgelist$V2, levels = levels(fac)))
    edgelist$V1 <- edgelist$V1 - 1
    edgelist$V2 <- edgelist$V2 - 1
}

uniqueIds <- unique(c(edgelist$V1, edgelist$V2))
numIds <- length(uniqueIds)
stopifnot(min(uniqueIds) == 0)
stopifnot(max(uniqueIds) == numIds - 1)


## have to add 1 as igraph cannot handle 0 as vertex id apparently
g <- graph.edgelist(as.matrix(edgelist)+1, directed=TRUE)


summary(g)
## remove multiple and self edges
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)


write.graph(g, outfilename, format="pajek")

