#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args) < 5) {
  stop("Usage\nscript.R <recalling.ped> <ukbb_file.geno.txt>  <int.tsv> <title> <outfile>\n", call.=FALSE)
} else if (length(args)>=1) {
  ukbb = args[2]
  recall = args[1]
  intensity = args[3]
  t1 = args[4]
  outfile = args[5]
}


df = read.table(ukbb, header=FALSE,sep='\t')
df[,1] = as.numeric(df[,1])
recall = read.table(recall,header=FALSE,sep='\t')
#subsetting the ped file
recall = recall[c("V1","V7")]
intensity = read.table(intensity, header=TRUE,sep='\t')

library(scales) #use to add transparency
#png(paste0(outfile,"_genotyped.pdf"), width=6, height=6)
#png(paste0(outfile,"_recalled.pdf"),width=6,height=6)
#par(mfrow=c(1,2))
#par(oma=c(1,1,1,1))

print('Merging UKBB genotypes to new calls...')
merge.df<-merge(recall,df,by.x="V1",by.y="V1")

print('Merging also intensity file...')
#delete Person column ID from the merged.df
merge.df<-merge(merge.df,intensity,by.x="V1",by.y="Person")
merge.df<-merge.df[, !(names(merge.df) %in% c("Person"))]
#print(str(merge.df))

lev_recall<-levels(merge.df[,2])
lev_recall<-lev_recall[! lev_recall %in% c("0 0")]
lev_ukbb<-levels(merge.df[,3])
lev_ukbb<-lev_ukbb[! lev_ukbb %in% c("0 0")]

i=max(length(lev_ukbb),length(lev_recall))
if (length(lev_recall)!=i) {
	lev<-lev_ukbb
} else {
	lev<-lev_recall
}

cnames<-c("0 0")
cnames<-c(cnames,lev)
print('Generating the plot...')
merge.df$ColorRecall="black"
colors<-c("#1b9e77","#d95f02")
num.geno.recall<-list()
num.geno.recall<-c(num.geno.recall,sum(merge.df[,2]=="0 0"))
#lev_recall<-levels(merge.df[,2])
col_recall<-list()
#lev_recall<-lev_recall[! lev_recall %in% c("0 0")] #remove the missing from levels
counter<-1
for (c in lev) {
	merge.df$ColorRecall[merge.df[,2]==c]=colors[counter]
	col_recall<-c(col_recall,colors[counter])
	num.geno.recall<-c(num.geno.recall,sum(merge.df[,2]==c))
	counter = counter+1
}

merge.df$ColorUKBB="black"
num.geno.ukbb<-list()
num.geno.ukbb<-list()
num.geno.ukbb<-c(num.geno.ukbb,sum(merge.df[,3]=="0 0"))
#lev_ukbb<-levels(merge.df[,3])
col_ukbb<-list()
#lev_ukbb<-lev_ukbb[! lev_ukbb %in% c("0 0")] #remove the missing from levels
counter<-1
for (c in lev) {
        merge.df$ColorUKBB[merge.df[,3]==c]=colors[counter]
        col_ukbb<-c(col_ukbb,colors[counter])
	num.geno.ukbb<-c(num.geno.ukbb,sum(merge.df[,3]==c))
        counter = counter+1
}

num.geno.ukbb<-unlist(num.geno.ukbb)
num.geno.recall<-unlist(num.geno.recall)

num.geno.ukbb<-as.data.frame(num.geno.ukbb)
num.geno.recall<-as.data.frame(num.geno.recall)
rownames(num.geno.recall)<-cnames
rownames(num.geno.ukbb)<-cnames #because usually the recall should have all three but it is not the best solution!
num.geno.df<-cbind(num.geno.recall,num.geno.ukbb)
#rownames(num.geno.df)<-c("Recall","UKBB")
colnames(num.geno.df)<-c("Recall","UKBB")

lev<-c(lev,"0 0")		
col_recall<-c(col_recall,"black")
col_recall<-unlist(col_recall)
#lev_ukbb<-c(lev_ukbb,"0 0")
col_ukbb<-c(col_ukbb,"black")
col_ukbb<-unlist(col_ukbb)
print(head(merge.df))


write.table(num.geno.df,file=paste0(t1,".stats.tsv"),sep='\t',row.names=TRUE,col.names=TRUE,quote=FALSE)

jpeg(paste0(outfile,"_recalled.jpg"),width=6,height=6,units="in",res=300)
#par(oma=c(1,1,1,1))
print("Fist plot...")
plot(merge.df[,4],merge.df[,5],main=paste0(t1," Recall"),xlab="A allele",ylab="B allele",bg=alpha(merge.df$ColorRecall,0.8),col=merge.df$ColorRecall,pch=21)
legend('topright', legend=lev,col=col_recall,cex=0.6,pch=21)
dev.off()

jpeg(paste0(outfile,"_genotyped.jpg"),width=6,height=6,units="in",res=300)
#par(oma=c(1,1,1,1))

print("Second plot...")
plot(merge.df[,4],merge.df[,5],main=paste0(t1," UKBB"),xlab="A allele",ylab="B allele",bg=alpha(merge.df$ColorUKBB,0.8),col=merge.df$ColorUKBB,pch=21)
legend('topright', legend=lev,col=col_ukbb,cex=0.6,pch=21)
dev.off()
print("Done!")

