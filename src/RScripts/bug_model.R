library(pscl)
library(car)
library(sqldf)
library(xtable)
library(stargazer)
#model_full_glm_binomial = glm(total_bug > 0 ~ total_add + dev + total_assert, family = "binomial", data = ms_scale)

#m = read.csv("MyWork/MyCurrent/Ray_asserts_paper_ICSE2015/inputs_sep3/method_assert.csv")
#Current set to replicate ICSE -> same dates, no big commit filtering.
m <- read.csv("~/assert_project_repos/assert/data/method_assert_everything_before_ICSE_no_merge.csv")
m <- read.csv("~/assert_project_repos/assert/data/method_assert_everything_before_ICSE_no_merge_expanded.csv")

#No limit to ICSE
#m <- read.csv("~/assert_project_repos/assert/data/method_assert_everything_no_merge.csv")
#m <- read.csv("~/assert_project_repos/assert/data/method_assert_size_capped_smaller_before_ICSE_no_merge.csv")
#What needs to change to get the original results? -> I.e. what is the cause of the discrepancy
#How about if we ignore the initial commits? ... Nope, still positive.  
#Maybe it was combination of initial commits being ignored plus all being grouped in NA?
#Well, it doesn't seem to be that either, as removing the NA's in the original set keeps it negative...
#m <- read.csv("~/assert_project_repos/assert/data/method_assert_no_initial_before_ICSE_no_merge.csv")
#Replicate the original study...
#m <- read.csv("~/assert_project_repos/assert/data/method_assert_old.csv")
#Apply same filters to the old data as we do now..
#m <- read.csv("~/assert_project_repos/assert/data/method_assert_old_filtered.csv")
#Exact data set.
#m = read.csv("~/assert_project_repos/assert/data/method_assert.csv")
#These are somehow messing things up...

#Large leverage is 2 to 3 times (# of params/ # of observations)

is_C <- function(check)
{
	return(substr(check, nchar(check)-1, nchar(check)) == '.c')
}

m$tag <- sapply(as.character(m$file_name), is_C)

m = m[m$total_add > 0, ]
m_subset = m[m$assert_add <= 15 & m$total_bug <= 15 & m$total_add<=4000,] 
nrow(m_subset)/nrow(m)


# WHERE commit_date < \'2014-07-20;\'


m_subset$cd = 'L'
#ms_scale_wa$cd[ms_scale_wa$dev <= 2 & ms_scale_wa$dev > -0.1506] <- 'M'
m_subset$cd[m_subset$dev >  1] <- 'H'

m_subset$cd = factor(m_subset$cd)


#m_subset_h = m_subset[m_subset$cd == 'H',]
#m_subset_l = m_subset[m_subset$cd == 'L',]

#Looking at high vs low, no scaling first
#h_all = glm(total_bug  ~ log(total_add) + dev + total_assert, family = quasipoisson, data = m_subset_h)
#Dev is 1 here.
#l_all = glm(total_bug  ~ log(total_add) + total_assert, family = quasipoisson, data = m_subset_l)

ms_scale = m_subset[,c("assert_add","dev")]
ms_scale = data.frame(scale(as.matrix(ms_scale)))
ms_scale$total_bug = m_subset$total_bug
ms_scale$total_add = m_subset$total_add
ms_scale$tag = m_subset$tag

#model_full_bin_scale = glm(total_bug > 0 ~ log(total_add) + dev + total_assert, family = "binomial", data = ms_scale)

#zero = zeroinfl(formula = total_bug ~ log(total_add) + dev + total_assert, data = ms_scale)

#New models attempts
#model_full_bin_scale_2 = glm(total_bug > 0 ~ log(total_add) + dev + factor(total_assert>0), family = "binomial", data = ms_scale)
#model_full_scale = glm(total_bug ~ log(total_add) + dev + total_assert, family = quasipoisson, data = ms_scale)
#model_full_scale_2 = glm(total_bug ~ log(total_add) + dev + factor(total_assert>0), family = quasipoisson, data = ms_scale)


#FOR REWRITE (Need to get rid of perfect split (seems like we are missing something...))
model_full_bin_scale = glm(total_bug > 0 ~ log(total_add) + dev + assert_add, family = "binomial", data = ms_scale)
#model_full_bin_scale = glm(total_bug > 0 ~ log(total_add) + dev + assert_add + factor(tag), family = "binomial", data = ms_scale)
#rewrite_model <- hurdle(formula = total_bug ~ log(total_add) + dev + total_assert, 
#    data = ms_scale, dist = "negbin", zero.dist = "negbin")

#After looking at the anovas, I don't think removing these is a good idea?

#Identify and remove high leverage points
# cutoff <- 2*(4/nrow(ms_scale)) 
# lev <- hatvalues(model_full_bin_scale)
# levLarge <- lev > cutoff #Get these out...
# ms_scale_low_lev <- ms_scale[levLarge == FALSE,]

# values <- cooks.distance(model_full_bin_scale)
# #large <- values > 4/nrow(ms_scale) #Alternative of 1 removes nothing (4/n makes anova of assert 1...)
# large <- values > .5
# ms_scale_low_cooks <- ms_scale[large == FALSE,]
# model_full_bin_scale_low_cooks = glm(total_bug > 0 ~ log(total_add) + dev + assert_add + factor(tag), family = "binomial", data = ms_scale_low_cooks)

#This splits the residuals... (Actually, this is expected for binomial regression)


m_subset_wa = m_subset[m_subset$assert_add > 0 & m_subset$total_bug > 0,] 
ms_scale_wa = m_subset_wa[,c("assert_add","dev")]
ms_scale_wa = data.frame(scale(as.matrix(ms_scale_wa)))
ms_scale_wa$total_bug = m_subset_wa$total_bug
ms_scale_wa$total_add = m_subset_wa$total_add
ms_scale_wa$tag = m_subset_wa$tag

model_assert_scale  =  glm(total_bug  ~ log(total_add) + dev + assert_add + factor(tag), 
                           family = quasipoisson, data = ms_scale_wa)

# values <- cooks.distance(model_assert_scale)
# large <- values > 4/nrow(ms_scale_wa) #Alternative of 1 removes nothing
# low_cooks <- ms_scale_wa[large == FALSE,]

# model_assert_scale_low_cooks  =  glm(total_bug  ~ log(total_add) + dev + assert_add + factor(tag), 
#                            family = quasipoisson, data = low_cooks)


# ms_scale_wa$cd = 'L'
# #ms_scale_wa$cd[ms_scale_wa$dev <= 2 & ms_scale_wa$dev > -0.1506] <- 'M'
# ms_scale_wa$cd[ms_scale_wa$dev >  median(ms_scale_wa$dev)] <- 'H'

# ms_scale_wa$cd = factor(ms_scale_wa$cd)

# ms_scale_wa_h = ms_scale_wa[ms_scale_wa$cd == 'H',]
# ms_scale_wa_l = ms_scale_wa[ms_scale_wa$cd == 'L',]

# h = glm(total_bug  ~ log(total_add) + dev + assert_add + factor(tag), family = quasipoisson, data = ms_scale_wa_h)
# l = glm(total_bug  ~ log(total_add) + dev + assert_add + factor(tag), family = quasipoisson, data = ms_scale_wa_l)

#Remove high cooks again...

# values <- cooks.distance(h)
# large <- values > 4/nrow(ms_scale_wa_h)
# low_cooks_h <- ms_scale_wa_h[large == FALSE,]

# values <- cooks.distance(l)
# large <- values > 4/nrow(ms_scale_wa_l)
# low_cooks_l <- ms_scale_wa_l[large == FALSE,]

# #No change - did baishakhi do something different?
# h_low_cooks = glm(total_bug  ~ log(total_add) + dev + assert_add + factor(tag), family = quasipoisson, data = low_cooks_h)
# l_low_cooks = glm(total_bug  ~ log(total_add) + dev + assert_add + factor(tag), family = quasipoisson, data = low_cooks_l)

#What about the split on the whole data?????




########


##########
#m_subset_no_bug = m_subset[m_subset$total_bug > 0,] 
#ms_scale_no_bug = m_subset_no_bug[,c("total_assert","dev")]
#ms_scale_no_bug = data.frame(scale(as.matrix(ms_scale_no_bug)))
#ms_scale_no_bug$total_bug = m_subset_no_bug$total_bug
#ms_scale_no_bug$total_add = m_subset_no_bug$total_add

#model_nobug_scale  =  glm(total_bug  ~ log(total_add) + 
#                            dev * total_assert, 
#                          family = quasipoisson, data = m_subset_no_bug)


##########
m_subset_wa = m_subset[m_subset$assert_add > 0 & m_subset$total_bug > 0,] 
ms_scale_wa = m_subset_wa[,c("assert_add","dev")]
ms_scale_wa = data.frame(scale(as.matrix(ms_scale_wa)))
ms_scale_wa$total_bug = m_subset_wa$total_bug
ms_scale_wa$total_add = m_subset_wa$total_add

model_assert_scale  =  glm(total_bug  ~ log(total_add) + dev + assert_add, 
                           family = quasipoisson, data = ms_scale_wa)


# require('stargazer')
# #stargazer(model_full_bin_scale,model_assert_scale,single.row = TRUE,
# #          out="/Users/bray/paper/assert_paper/tables/model_bug_all_scale1.tex")

# #xtable(anova(model_assert_scale), out='~/paper/assert_paper/tables/model_bug_all_scale_anova1.tex')

# require('stargazer')
 stargazer(model_full_bin_scale,model_assert_scale,single.row = TRUE,
           out="~/assert_project_repos/assertPaperFinal/Replication/model_bug_all_scale_revised.tex")


print(xtable(anova(model_assert_scale)),
      file='~/assert_project_repos/assertPaperFinal/Replication/model_nobug_scale_anova_revised.tex')
print(xtable(anova(model_full_bin_scale)),
      file='~/assert_project_repos/assertPaperFinal/Replication/model_hurdle_anova_revised.tex')

# print(xtable(anova(model_assert_scale)),
#       file='~/paper/assert_paper/tables/model_nobug_scale_anova.tex')
# print(xtable(anova(model_full_bin_scale)),
#       file='~/paper/assert_paper/tables/model_hurdle_anova.tex')



# ms_scale$cd = 'L'
# #ms_scale_wa$cd[ms_scale_wa$dev <= 2 & ms_scale_wa$dev > -0.1506] <- 'M'
# ms_scale$cd[ms_scale$dev >  median(ms_scale$dev)] <- 'H'

# ms_scale$cd = factor(ms_scale$cd)


# ms_scale_h = ms_scale[ms_scale$cd == 'H',]
# ms_scale_l = ms_scale[ms_scale$cd == 'L',]

# h_scale = glm(total_bug  ~ log(total_add) + dev + total_assert, family = quasipoisson, data = ms_scale_h)
# l_scale = glm(total_bug  ~ log(total_add) + total_assert, family = quasipoisson, data = ms_scale_l)

ms_scale_wa$cd = 'L'
#ms_scale_wa$cd[ms_scale_wa$dev <= 2 & ms_scale_wa$dev > -0.1506] <- 'M'
ms_scale_wa$cd[ms_scale_wa$dev >  median(ms_scale_wa$dev)] <- 'H'

ms_scale_wa$cd = factor(ms_scale_wa$cd)

ms_scale_wa_h = ms_scale_wa[ms_scale_wa$cd == 'H',]
ms_scale_wa_l = ms_scale_wa[ms_scale_wa$cd == 'L',]

h = glm(total_bug  ~ log(total_add) + dev + assert_add, family = quasipoisson, data = ms_scale_wa_h)
l = glm(total_bug  ~ log(total_add) + dev + assert_add, family = quasipoisson, data = ms_scale_wa_l)

# stargazer(h,l, single.row = TRUE,
#           out="/Users/bray/paper/assert_paper/tables/model_bug_assert_bydev.tex")

stargazer(h,l, single.row = TRUE,out="~/assert_project_repos/assertPaperFinal/Replication/model_bug_assert_bydev_revised.tex")

# #print(xtable(anova(model_assert_scale)),file ='~/paper/assert_paper/tables/model_assert_scale_anova.tex')
# print(xtable(anova(h)), file='~/paper/assert_paper/tables/model_high_anova.tex')
# print(xtable(anova(l)), file='~/paper/assert_paper/tables/model_low_anova.tex')

print(xtable(anova(h)), file='~/assert_project_repos/assertPaperFinal/Replication/model_high_anova_revised.tex')
print(xtable(anova(l)), file='~/assert_project_repos/assertPaperFinal/Replication/model_low_anova_revised.tex')

#Before and after the assert was added.


#Note that this one is including .h and .cpp files.
assertBeforeAndAfter <- read.csv("~/assert_project_repos/assert/data/assertBeforeAndAfter.csv", header=FALSE)
colnames(assertBeforeAndAfter) <- c("b_project", "b_lang", "b_file", "b_test", "b_method", "b_assert_add", "b_assert_del", "b_total_add", "b_total_del", "b_bug", "b_dev","a_project", "a_lang", "a_file", "a_test", "a_method", "a_assert_add", "a_assert_del", "a_total_add", "a_total_del", "a_bug", "a_dev")
assertBeforeAndAfter <- sqldf("SELECT * FROM assertBeforeAndAfter WHERE b_file LIKE \'%.c\' OR b_file LIKE \'%.cc\' OR b_file LIKE '%.cpp' OR b_file LIKE '%.c++' OR b_file LIKE '%.cp' OR b_file LIKE '%.cxx';") #CohensD is slightly higher here, not really that different

#We can limit it before ICSE date, but it makes no difference...
#Again, similar behavior when including header files.
#The count of asserts here matches (almost - its like 60 off...) asserts in m when no capping by date, size, but by language...

assertBeforeAndAfter[is.na(assertBeforeAndAfter)] <- 0
View(assertBeforeAndAfter)

#Basic test
wilcox.test(assertBeforeAndAfter$b_bug, assertBeforeAndAfter$a_bug, paired=TRUE, alternative='less')
cohensD(assertBeforeAndAfter$b_bug, assertBeforeAndAfter$a_bug, method='paired')

#Normalize by lines added
beforeBugPerAdded <- assertBeforeAndAfter$b_bug/assertBeforeAndAfter$b_total_add
afterBugPerAdded <- assertBeforeAndAfter$a_bug/assertBeforeAndAfter$a_total_add
beforeBugPerAdded[is.na(beforeBugPerAdded)] <- 0
beforeBugPerAdded[is.infinite(beforeBugPerAdded)] <- assertBeforeAndAfter$b_bug[is.infinite(beforeBugPerAdded)]
afterBugPerAdded[is.na(afterBugPerAdded)] <- 0
afterBugPerAdded[is.infinite(afterBugPerAdded)] <- assertBeforeAndAfter$a_bug[is.infinite(afterBugPerAdded)]

wilcox.test(beforeBugPerAdded, afterBugPerAdded, paired=TRUE, alternative='less')
cohensD(beforeBugPerAdded, afterBugPerAdded, method='paired')

#Normalize by devs
beforeBugPerDev <- assertBeforeAndAfter$b_bug/assertBeforeAndAfter$b_dev
afterBugPerDev <- assertBeforeAndAfter$a_bug/assertBeforeAndAfter$a_dev
beforeBugPerDev[is.na(beforeBugPerDev)] <- 0
afterBugPerDev[is.na(afterBugPerDev)] <- 0

wilcox.test(beforeBugPerDev, afterBugPerDev, paired=TRUE, alternative='less')
cohensD(beforeBugPerDev, afterBugPerDev, method='paired')

#Normalize by net line change
beforeBugPerNet <- assertBeforeAndAfter$b_bug/(assertBeforeAndAfter$b_total_add-assertBeforeAndAfter$b_total_del)
beforeBugPerNet[is.na(beforeBugPerNet)] <- 0
beforeBugPerNet[is.infinite(beforeBugPerNet)] <- assertBeforeAndAfter$b_bug[is.infinite(beforeBugPerNet)]

afterBugPerNet <- assertBeforeAndAfter$a_bug/(assertBeforeAndAfter$a_total_add-assertBeforeAndAfter$a_total_del)
afterBugPerNet[is.na(afterBugPerNet)] <- 0
afterBugPerNet[is.infinite(afterBugPerNet)] <- assertBeforeAndAfter$b_bug[is.infinite(afterBugPerNet)]
wilcox.test(beforeBugPerNet, afterBugPerNet, paired=TRUE, alternative='greater') 
cohensD(beforeBugPerNet, afterBugPerNet, method='paired') #Very small, effect is slightly greater when unpaired..

#Corrective Asserts
buggyBefore <- assertBeforeAndAfter[assertBeforeAndAfter$b_bug > 0,]
wilcox.test(buggyBefore$b_bug, buggyBefore$a_bug, paired=TRUE, alternative='greater') 
cohensD(buggyBefore$b_bug, buggyBefore$a_bug, method='paired')

#Corrective with size normalization
beforeBugPerAdded2 <- buggyBefore$b_bug/buggyBefore$b_total_add
afterBugPerAdded2 <- buggyBefore$a_bug/buggyBefore$a_total_add
beforeBugPerAdded2[is.na(beforeBugPerAdded2)] <- 0
beforeBugPerAdded2[is.infinite(beforeBugPerAdded2)] <- buggyBefore$b_bug[is.infinite(beforeBugPerAdded2)]
afterBugPerAdded2[is.na(afterBugPerAdded2)] <- 0
afterBugPerAdded2[is.infinite(afterBugPerAdded2)] <- buggyBefore$a_bug[is.infinite(afterBugPerAdded2)]

wilcox.test(beforeBugPerAdded2, afterBugPerAdded2, paired=TRUE, alternative='greater')
cohensD(beforeBugPerAdded2, afterBugPerAdded2, method='paired')


beforeBugPerDev2 <-  buggyBefore$b_bug/buggyBefore$b_dev
afterBugPerDev2 <- buggyBefore$a_bug/buggyBefore$a_dev
beforeBugPerDev2[is.na(beforeBugPerDev2)] <- 0
afterBugPerDev2[is.na(afterBugPerDev2)] <- 0

wilcox.test(beforeBugPerDev2, afterBugPerDev2, paired=TRUE, alternative='less')
cohensD(beforeBugPerDev2, afterBugPerDev2, method='paired')

#Regressions on just buggyBefore + noAsserts
noAsserts <- m[m$total_assert == 0,]
#Want the total lines and devs in history, not just after assert?
temp = m
colnames(temp) <- c("b_project", "b_file", "b_method", "total_assert","total_add","total_bug", "dev")
#colnames(temp) <- c("b_project", "b_file", "b_method", "assert_add", "assert_del","total_add","total_del","total_bug", "dev","net_assert","assert_change","net_lines","line_change")
merged = merge(buggyBefore, temp, by = c("b_project", "b_file", "b_method"))
#Get the net assertion change
merged$NetAssert <- merged$b_assert_add + merged$a_assert_add - merged$b_assert_del - merged$a_assert_del
merged$AssertChange <- merged$b_assert_add + merged$a_assert_add + merged$b_assert_del + merged$a_assert_del


converted <- merged[,c(1,2,3,23,24,21,26)]
colnames(converted) <- c("project", "file_name", "method_name", "total_assert","total_add","total_bug", "dev")
combinedSample <- rbind(noAsserts, converted)
bug_New <- glm(total_bug > 0 ~ log(total_add) + dev + total_assert, family = "binomial", data = combinedSample)

converted2 <- merged[,c(1,2,3,27,24,21,26)]
colnames(converted2) <- c("project", "file_name", "method_name", "net_assert","total_add","total_bug", "dev")
colnames(noAsserts) <- c("project", "file_name", "method_name", "net_assert","total_add","total_bug", "dev")
combinedSample2 <- rbind(noAsserts, converted2)
bug_New2 <- glm(total_bug > 0 ~ log(total_add) + dev + net_assert, family = "binomial", data = combinedSample2)

converted3 <- merged[,c(1,2,3,28,24,21,26)]
colnames(converted3) <- c("project", "file_name", "method_name", "assert_change","total_add","total_bug", "dev")
colnames(noAsserts) <- c("project", "file_name", "method_name", "assert_change","total_add","total_bug", "dev")
combinedSample3 <- rbind(noAsserts, converted3)
combinedSample3$net_assert <- combinedSample2$net_assert
bug_New3 <- glm(total_bug > 0 ~ log(total_add) + dev + assert_change + net_assert, family = "binomial", data = combinedSample3)

bug_New4 <- glm(total_bug ~ log(total_add) + dev + assert_change + net_assert, family = "quasipoisson", data = combinedSample3)

bug_New5 <- zeroinfl(total_bug ~ log(total_add) + dev + assert_change + net_assert, data = combinedSample3)

method_assert_everything_no_merge_expanded <- read.csv("~/assert_project_repos/assert/data/method_assert_everything_before_ICSE_no_merge_expanded.csv")
   View(method_assert_everything_no_merge_expanded)
m <- method_assert_everything_no_merge_expanded
m$net_assert <- m$assert_add - m$assert_del
m$assert_change <- m$assert_add + m$assert_del
m$net_lines <- m$total_add - m$total_del
m$line_change <- m$total_add + m$total_del

#ols=lm(total_bug ~ line_change + net_lines + dev + assert_change + net_assert, data = m)  
  
#d1 <- cooks.distance(ols)
#r <- stdres(ols)
#a <- cbind(m, d1, r)
#m = a[d1 <= 4/nrow(m), ]


m <- m[m$line_change > 0,]
m <- m[m$assert_change <= 15 & m$total_bug <= 15 & m$line_change <= 4000,]

#Note -> the correlations are all positive by themselves.
cor(m[,c(8,9,10,11,12,13)])
#bugmodel <- glm(total_bug ~ line_change + net_lines + dev + assert_change + net_assert, family = "quasipoisson", data = m)
bugmodelzero <- zeroinfl(total_bug ~ log(line_change) + net_lines + dev + assert_change + net_assert, data = m)
bugmodelzero2 <- zeroinfl(total_bug ~ log(line_change) + net_lines + dev + assert_change + net_assert, dist = "negbin", data = m)
bugmodelnb <- glm.nb(total_bug ~ log(line_change) + net_lines + dev + assert_change + net_assert, data = m)
bugmodelhurdle <- hurdle(total_bug ~ log(line_change) + net_lines + dev + assert_change + net_assert, dist = "negbin", data = m)

#This isn't quite right, I'm not excluding the changes from before...
notBuggyBefore <- assertBeforeAndAfter[assertBeforeAndAfter$b_bug == 0,]
b <- m
b$key <- paste(as.character(b$project),as.character(b$file_name),as.character(b$method_name))
notBuggyBefore$key <- paste(as.character(notBuggyBefore$b_project), as.character(notBuggyBefore$b_file), as.character(notBuggyBefore$b_method))
b <- b[b$key != notBuggyBefore$key,]

bugmodel2 <- glm(total_bug ~ line_change + net_lines + dev + assert_change + net_assert, family = "quasipoisson", data = b)