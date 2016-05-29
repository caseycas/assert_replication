library(pscl)
library(car)
library(sqldf)
library(xtable)
library(stargazer)
#model_full_glm_binomial = glm(total_bug > 0 ~ total_add + dev + total_assert, family = "binomial", data = ms_scale)

#m = read.csv("MyWork/MyCurrent/Ray_asserts_paper_ICSE2015/inputs_sep3/method_assert.csv")
#Current set to replicate ICSE -> same dates, no big commit filtering.
m <- read.csv("../../data/Csvs/R_Inputs/method_assert_everything_before_ICSE_no_merge.csv")
m <- read.csv("../../data/Csvs/R_Inputs/method_assert_everything_before_ICSE_no_merge_expanded.csv")

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
           out="../../data/Outputs/model_bug_all_scale_revised.tex")


print(xtable(anova(model_assert_scale)),
      file='../../data/Outputs/model_nobug_scale_anova_revised.tex')
print(xtable(anova(model_full_bin_scale)),
      file='../../data/Outputs/model_hurdle_anova_revised.tex')

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

stargazer(h,l, single.row = TRUE,out="../../data/Outputs/model_bug_assert_bydev_revised.tex")

# #print(xtable(anova(model_assert_scale)),file ='~/paper/assert_paper/tables/model_assert_scale_anova.tex')
# print(xtable(anova(h)), file='~/paper/assert_paper/tables/model_high_anova.tex')
# print(xtable(anova(l)), file='~/paper/assert_paper/tables/model_low_anova.tex')

print(xtable(anova(h)), file='../../data/Outputs/model_high_anova_revised.tex')
print(xtable(anova(l)), file='../../data/Outputs/model_low_anova_revised.tex')