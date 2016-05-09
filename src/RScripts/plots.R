library(sqldf)
library(lsr)

#Old data
#maiin<-read.csv("~/assert_project_repos/assertPaperFinal/Data/MethodAssertInfo.csv",quote="")
#muaiin<-read.csv("~/assert_project_repos/assertPaperFinal/Data/MethodUserAssertInfo.csv",quote="")
#New data
maiin<-read.csv("~/assert_project_repos/assert/data/MethodAssertInfoNoMerge.csv",quote="")
muaiin<-read.csv("~/assert_project_repos/assert/data/MethodUserAssertInfoNoMerge.csv",quote="")
mai<-maiin[maiin$Method != "" ,]

pdf("~/assert_project_repos/assert/commit-rate-per-dev-box.pdf",width=5, height=4)
boxplot(data=mai,(Total.Added+Total.Removed+0.01)/Committer.Count~(Asserts.Added>0),log="y",names=c("No Asserts","Some Asserts"),ylab="Lines per committer (log scale)",main="Code per committer in non-Test files",outline=FALSE)
dev.off()

pdf("~/assert_project_repos/assert/ownership-dev-box.pdf",width=5, height=4)
muai=muaiin[muaiin$Method != "" & muaiin$Author != 'None',]
muai$Ownership=muai$Author.Total.Commits/muai$Total.Method.Commits
boxplot(data=muai,Ownership~(Asserts.Added == 0),names=c("Added Asserts","Didn't Add Asserts"),ylab="Ownership",main="Ownership of Developers",outline=FALSE)
dev.off()


mua<-muai[muai$Author!= 'None',]
mua$atc=mua$Author.Total.Commits
mya=mua[mua$Asserts.Added !=0 ,]
mnein=mua[mua$Asserts.Added ==0,]

myas=sqldf("select Project,Filename,Method, Median(atc) from mya group by Project, Filename,Method")
mneins=sqldf("select Project,Filename,Method, Median(atc) from mnein group by Project, Filename,Method")
names(myas)=c("Project","Filename","Method","Yesexp")

names(mneins)=c("Project","Filename","Method","Noexp")
mall<-merge(myas,mneins)
mall$yes=as.numeric(mall$Yesexp)
mall$no=as.numeric(mall$Noexp)
pdf("~/assert_project_repos/assert/experience-dev-box.pdf",width=5, height=4)
boxplot(mall$yes,mall$no,names=c("Added Asserts","Didn't Add Asserts"),ylab="Median Experience",main="Experience of Developers",outline=FALSE)
dev.off()


#Wilcox test for ownership
muaiA <- muai[muai$Asserts.Added > 0,]
muaiNA <- muai[muai$Asserts.Added == 0,]
wilcox.test(muaiA$Ownership, muaiNA$Ownership, alternative = 'greater')
cohensD(muaiA$Ownership, muaiNA$Ownership)

#Wilcox test for experience
wilcox.test(mall$yes, mall$no, alternative='greater', paired=TRUE)
cohensD(mall$yes, mall$no)


