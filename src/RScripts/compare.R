library(lsr)
library(sqldf) #David recommends looking at data.table package

m <- read.csv("~/assert_project_repos/assert/data/method_assert_old_filtered.csv")

mFull <- read.csv("~/assert_project_repos/assert/data/method_assert_everything_before_ICSE_no_merge.csv")
#Try with size cap and initial commits removed:
#mFull <- read.csv("~/assert_project_repos/assert/data/method_assert_capped_no_initial_before_ICSE_no_merge.csv")
View(mFull)


mMerged <- merge(m, mFull, by = c("project", "file_name", "method_name")) 
colnames(mMerged) <- c("project", "file_name", "method_name", "oldAssert", "oldAdd", "oldBug", "oldDev", "newAssert", "newAdd", "newBug", "newDev")

#Do the same filtering

mMerged = mMerged[mMerged$oldAdd > 0, ]
mMerged = mMerged[mMerged$newAdd > 0, ]
mMerged = mMerged[mMerged$oldAssert <= 15 & mMerged$oldBug <= 15 & mMerged$oldAdd<=4000,] 
mMerged = mMerged[mMerged$newAssert <= 15 & mMerged$newBug <= 15 & mMerged$newAdd<=4000,] 

#Check the differences...
mMerged$addDiff = mMerged$newAdd - mMerged$oldAdd
mMerged$assertDiff = mMerged$newAssert - mMerged$oldAssert
mMerged$bugDiff = mMerged$newBug - mMerged$oldBug
mMerged$devDiff = mMerged$newDev - mMerged$oldDev
View(mMerged)

wilcox.test(mMerged$oldAssert,mMerged$newAssert, paired=TRUE)
wilcox.test(mMerged$oldDev,mMerged$newDev, paired=TRUE)
wilcox.test(mMerged$oldBug,mMerged$newBug, paired=TRUE)
wilcox.test(mMerged$oldAdd,mMerged$newAdd, paired=TRUE)

#When filtering on the exact same functions, # of devs who touched them goes way up...
#This is from method_assert_before_ICSE_no_merge.csv and method_assert_old_filtered.csv
cohensD(mMerged$oldAssert,mMerged$newAssert, method='paired') #0.1034291
cohensD(mMerged$oldDev,mMerged$newDev, method='paired') #0.7683287
cohensD(mMerged$oldBug,mMerged$newBug, method='paired') #0.5469341
cohensD(mMerged$oldAdd,mMerged$newAdd, method='paired') #0.255514


ms_scale = mMerged[,c("oldAssert","oldDev", "newAssert", "newDev")]
ms_scale = data.frame(scale(as.matrix(ms_scale)))
ms_scale$oldBug = mMerged$oldBug
ms_scale$oldAdd = mMerged$oldAdd
ms_scale$newBug = mMerged$newBug
ms_scale$newAdd = mMerged$newAdd

#These are still inconsistent...
hurdleOld = glm(oldBug > 0 ~ log(oldAdd) + oldDev + oldAssert, family = "binomial", data = ms_scale)
hurdleNew = glm(newBug > 0 ~ log(newAdd) + newDev + newAssert, family = "binomial", data = ms_scale)
hurdleNewWithOldBug = glm(oldBug > 0 ~ log(newAdd) + newDev + newAssert, family = "binomial", data = ms_scale) # Positive, but really

#Compare the base table
diffTable <- read.csv("~/assert_project_repos/assert/data/diffTable.csv", header=FALSE)

colnames(diffTable) <- c("project", "sha", "language", "file_name", "is_test", "method_name", "assertion_add_old", 
       "assertion_del_old", "assertion_add_new", "assertion_del_new", "total_add_old", 
       "total_del_old", "total_add_new", "total_del_new", "is_bug_old", "is_bug_new", 
       "author", "commit_date")

View(diffTable)
wilcox.test(diffTable$total_add_old, diffTable$total_add_new, paired=TRUE)
wilcox.test(diffTable$assertion_add_old, diffTable$assertion_add_new, paired=TRUE)

#The effect size differences here seem very small...
#I think the major issues come from the mislabeled parts.
#So how big are those?  What is the behavior when we exclude them?
cohensD(diffTable$total_add_old, diffTable$total_add_new, method='paired')
cohensD(diffTable$assertion_add_old, diffTable$assertion_add_new, method='paired')

#But first, check the differences in the bug table.
tp <- 0 # Was bug in original and in new
fp <- 0 # Was bug in original, not in new
fn <- 0 # Was bug in original, not in new
tn <- 0 # Not bug in original and in new


for(i in 1:nrow(diffTable))
{
	if(diffTable$is_bug_old[i] == 't' && diffTable$is_bug_new[i] == 't')
	{
		tp <- tp + 1
	}
	else if(diffTable$is_bug_old[i] == 't' && diffTable$is_bug_new[i] == 'f')
	{
		fp <- fp + 1
	}
	else if(diffTable$is_bug_old[i] == 'f' && diffTable$is_bug_new[i] == 't')
	{
		fn <- fn + 1
	}
	else if(diffTable$is_bug_old[i] == 'f' && diffTable$is_bug_new[i] == 'f')
	{
		tn <- tn + 1
	}
	else
	{
		print("Unrecognized bug labels at " + i)
		break;
	}
}

crossTable <- matrix(c(tp, fp, fn, tn), nrow = 2, ncol = 2, byrow = TRUE)
rownames(crossTable) <- c("Old_True", "Old_False")
colnames(crossTable) <- c("New_True", "New_False")

mcnemar.test(factor(diffTable$is_bug_old), factor(diffTable$is_bug_new))

relabel <- function(x) 
{
	if(x == 't')
	{
		return(1)
	} 
	else
	{
		return(0)
	}
}

#Reproduce the aggregates
#diffTable$is_bug_old_num <- lapply(diffTable$is_bug_old, relabel)
#diffTable$is_bug_new_num <- lapply(diffTable$is_bug_new, relabel)
#Wierd errors, related to having dates in the dataframe?
#diffAgg <- sqldf("SELECT project, file_name, method_name, sum(assertion_add_old), sum(assertion_del_old), sum(assertion_add_new), sum(assertion_del_new), sum(total_add_old), sum(total_del_old), sum(total_add_new), sum(total_del_new), sum(is_bug_old_num), sum(is_bug_new_num), count(DISTINCT(author)) FROM diffTable GROUP BY project, file_name, method_name;")

diffAgg <- read.csv("~/assert_project_repos/assert/data/diffAgg.csv", header=FALSE)
colnames(diffAgg) <- c("project", "file_name",  "method_name", "assertion_add_old", 
       "assertion_del_old", "assertion_add_new", "assertion_del_new", "total_add_old", 
       "total_del_old", "total_add_new", "total_del_new", "old_bug", "new_bug", 
       "developers")

diffAgg = diffAgg[diffAgg$total_add_old > 0, ]
diffAgg = diffAgg[diffAgg$total_add_new > 0, ]
diffAgg = diffAgg[diffAgg$assertion_add_old <= 15 & diffAgg$old_bug <= 15 & diffAgg$total_add_old<=4000,] 
m_subset2 = diffAgg[diffAgg$assertion_add_new <= 15 & diffAgg$new_bug <= 15 & diffAgg$total_add_new<=4000,]

View(m_subset2)

ms_scale2 = m_subset2[,c("assertion_add_old","assertion_add_new", "developers")]
ms_scale2 = data.frame(scale(as.matrix(ms_scale2)))
ms_scale2$old_bug = m_subset2$old_bug
ms_scale2$total_add_old = m_subset2$total_add_old
ms_scale2$new_bug = m_subset2$new_bug
ms_scale2$total_add_new = m_subset2$total_add_new

hurdleOld2 = glm(old_bug > 0 ~ log(total_add_old) + developers + assertion_add_old, family = "binomial", data = ms_scale2)
hurdleNew2 = glm(new_bug > 0 ~ log(total_add_new) + developers + assertion_add_new, family = "binomial", data = ms_scale2)
hurdleNewWithOldBug2 = glm(old_bug > 0 ~ log(total_add_new) + developers + assertion_add_new, family = "binomial", data = ms_scale2)


