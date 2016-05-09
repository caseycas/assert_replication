#buggyCommits <- read.csv("~/assert_project_repos/assert/data/buggyCommits.csv", header=FALSE)
buggyCommits <- read.csv("~/assert_project_repos/assert/data/bug_study_2.csv", header=FALSE)

names(buggyCommits) <- c("project", "sha", "author","commit_date","is_bug")
View(buggyCommits)

projects <- unique(buggyCommits$project)
pCount <- length(unique(buggyCommits$project))
balancedSample <- data.frame(project = character(), sha = character(), author=character(), commit_date = as.Date(character()), is_bug = character())
sampleSize <- 10
nextSlot <- 1
#Even out the odds of each project being selected as much as possible
for (i in 1:pCount) 
{
	nextProject <- buggyCommits[buggyCommits$project == projects[i],1:5]
	if(nrow(nextProject) < 10)
	{
 		sampleSize <- nrow(nextProject)
	}
	else
	{
		sampleSize <- 10
	}

	pSample <- nextProject[sample(nrow(nextProject), sampleSize),]

	balancedSample <- rbind(balancedSample, pSample) 
	nextSlot <- nextSlot + sampleSize
}

View(balancedSample)
#Select a another smaller random sample of 100 from this set.

bugSample <- balancedSample[sample(nrow(balancedSample), 100),]
View(bugSample)

write.table(bugSample, "bugSample.csv", sep = ",", row.names=FALSE)
