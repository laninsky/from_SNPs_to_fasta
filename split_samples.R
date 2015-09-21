intable <- read.table("temp",header=FALSE,stringsAsFactors=FALSE,sep="\t")
samplenames <- read.table("samplenamelist.txt",header=FALSE,stringsAsFactors=FALSE,sep="\t")
namefile <- read.table("namefile",header=FALSE,stringsAsFactors=FALSE,sep="\t")

rows <- dim(intable)[1]
no_taxa <- dim(samplenames)[1]*2

to_write <- matrix(NA,ncol=1,nrow=no_taxa)
to_write[1,1] <- intable[1,1]

to_write_title <- 2
sequencepaste <- NULL

for (j in 2:rows) {
if ((length(grep(">",intable[j,1])))>0) {
to_write_seq <- to_write_title
to_write_title <- to_write_title + 1
to_write[to_write_seq,1] <- sequencepaste
to_write[to_write_title,1] <- intable[j,1]
to_write_title <- to_write_title + 1
sequencepaste <- NULL
} else {
sequencepaste <- paste(sequencepaste,intable[j,1],sep="")
}
}

to_write[no_taxa,1] <- sequencepaste

rows <- dim(to_write)[1]

j <- 1

while (j < rows) {
for (i in 1:(no_taxa/2)) {
if ((length(grep(samplenames[i,1],to_write[j,1])))>0) {
outputname <- paste(sub(">","",samplenames[i,1]),".fa",sep="")
output <- rbind(paste(">",namefile[1,1],sep=""),to_write[(j+1),1])
j <- j + 2
write.table(output, outputname,quote=FALSE, col.names=FALSE,row.names=FALSE, append=TRUE)
break
}
}
}

q()
