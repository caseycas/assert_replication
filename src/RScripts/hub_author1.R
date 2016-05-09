#require("sna")
require("igraph")
require("reshape2")

calcHub <- function(cg, project) {

  proj = subset(cg, project_name==project) #cg is src file
  proj =  proj[,c("caller","callee","count")]
  
  g = graph.data.frame(proj, directed=TRUE, vertices=NULL)
  #E(g)$weight <- proj$count

  hub_score = hub.score(g, scale = TRUE)
  n = length(hub_score$vector)
  df <- data.frame(project = character(n), method = character(n),
                   mode = character(n),   degree  = numeric(n),
                   stringsAsFactors = FALSE)
  df$project = project
  df$mode    = "hub"
  hv = hub_score$vector
  for (i in 1:length(hv)) { 
    df$method[i] = names(hv[i])
    df$degree[i] = hv[[i]]
  }
  return(df)
}


calcAuth <- function(cg, project) {

  proj = subset(cg, project_name==project) #cg is src file
  proj =  proj[,c("caller","callee","count")]
  
  g = graph.data.frame(proj, directed=TRUE, vertices=NULL)
  #E(g)$weight <- proj$count

  auth_score = authority.score(g, scale = TRUE)
  n = length(auth_score$vector)
  df <- data.frame(project = character(n), method = character(n),
                   mode = character(n),   degree  = numeric(n),
                   stringsAsFactors = FALSE)
  df$project = project
  df$mode    = "auth"
  hv = auth_score$vector
  for (i in 1:length(hv)) { 
    df$method[i] = names(hv[i])
    df$degree[i] = hv[[i]]
  }
  return(df)
}

DegreeCentralityAll <- function(cgSrc) {
  
  df <- data.frame()

  cg = cgSrc #subset(cgSrc, project_name!='gcc')
  for (p in unique(cg$project_name)) {
    cat(sprintf("======= %s ========\n",p))
    df1 = calcHub(cg,p)
    df = rbind(df,df1)
  }
  cat(sprintf("======= !!!Done ========\n"))
  return(df)
}

cg = read.csv("inputs/assert.true_call_graph.csv")
df <- DegreeCentralityAll(cg)
write.table(df,'result/hub.csv',append=FALSE,row.names=FALSE,sep=",")
