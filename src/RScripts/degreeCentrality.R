#require("sna")
require("igraph")
require("reshape2")

Betweenness <- function(cg, project) {

  proj = subset(cg, project_name==project) #cg is src file
  proj =  proj[,c("caller","callee","count")]
  
  g = graph.data.frame(proj, directed=TRUE, vertices=NULL)
  #E(g)$weight <- proj$count

  m_bet = betweenness(g, directed = FALSE)
  n = length(m_bet)
  df <- data.frame(project = character(n), method = character(n),
                   mode = character(n),   degree  = numeric(n),
                   stringsAsFactors = FALSE)
  df$project = project
  df$mode    = "between"
  
  for (i in 1:length(m_bet)) { 
    df$method[i] = names(m_bet[i])
    df$degree[i] = m_bet[[i]]
  }
  return(df)
}


calDegree <- function(cg, project, degree_mode) {

  proj = subset(cg, project_name==project) #cg is src file
  proj =  proj[,c("caller","callee","count")]
  
  g = graph.data.frame(proj, directed=TRUE, vertices=NULL)
  #E(g)$weight <- proj$count

  m_degree = degree(g, mode=degree_mode)
  n = length(m_degree)
  df <- data.frame(project = character(n), method = character(n),
                   mode = character(n),   degree  = numeric(n),
                   stringsAsFactors = FALSE)
  df$project = project
  df$mode    = degree_mode
  
  for (i in 1:length(m_degree)) { 
    df$method[i] = names(m_degree[i])
    df$degree[i] = m_degree[[i]]
  }
  return(df)
}

DegreeCentralityAll <- function(cgSrc) {
  
  df <- data.frame()

  cg = cgSrc #subset(cgSrc, project_name!='gcc')
  for (p in unique(cg$project_name)) {
    cat(sprintf("======= %s ========\n",p))
    #df1 = calDegree(cg,p,"in")
    #df = rbind(df,df1)
    df1 = Betweenness(cg,p)
    df = rbind(df,df1)
  }
  cat(sprintf("======= !!!Done ========\n"))
  return(df)
}

cg = read.csv("inputs/assert.true_call_graph.csv")
df <- DegreeCentralityAll(cg)
write.table(df,'result/betweeness.csv',append=FALSE,row.names=FALSE,sep=",")
