require('lsr')

indegree<-function(assert, nassert){

  #Indegree: 
  res = t.test(assert$in_degree, nassert$in_degree)
  d   = cohensD(assert$in_degree, nassert$in_degree)
  cat(sprintf("in_degree,%s,%d,%.2f to %.2f,%g,%f,%f,%f\n", 
        unique(assert$project)[1], nrow(assert),res$conf.int[1], res$conf.int[2], 
        res$p.value, res$estimate[1], res$estimate[2], d[1]))
  
}

outdegree<-function(assert, nassert){
  
  #outdegree: 
  res = t.test(assert$out_degree, nassert$out_degree)
  d   = cohensD(assert$out_degree, nassert$out_degree)
  cat(sprintf("out_degree,%s,%d,%.2f to %.2f,%g,%f,%f,%f\n", 
        unique(assert$project)[1],  nrow(assert), res$conf.int[1], res$conf.int[2], 
        res$p.value, res$estimate[1], res$estimate[2], d[1]))

  
}

betw<-function(assert, nassert){

  #betweenness: 
  res = t.test(assert$betweenness, nassert$betweenness)
  d   = cohensD(assert$betweenness, nassert$betweenness)
  cat(sprintf("betweenness,%s,%d,%.2f to %.2f,%g,%f,%f,%f\n", 
        unique(assert$project)[1], nrow(assert), res$conf.int[1], res$conf.int[2], 
        res$p.value, res$estimate[1], res$estimate[2], d[1]))

}

hub<-function(assert, nassert) {

  #hub: 
  res = t.test(assert$hub, nassert$hub)
  d   = cohensD(assert$hub, nassert$hub)
  cat(sprintf("hub,%s,%d,%.2f to %.2f,%g,%f,%f,%f\n", 
        unique(assert$project)[1],  nrow(assert), res$conf.int[1], res$conf.int[2], 
        res$p.value, res$estimate[1], res$estimate[2], d[1]))

}

auth<-function(assert, nassert) {
  #auth: 
  res = t.test(assert$auth, nassert$auth)
  d   = cohensD(assert$auth, nassert$auth)
  cat(sprintf("auth,%s,%d,%.2f to %.2f,%g,%f,%f,%f\n", 
        unique(assert$project)[1], nrow(assert), res$conf.int[1], res$conf.int[2], 
        res$p.value, res$estimate[1], res$estimate[2], d[1]))
 
}


centralityAll<-function(all) {
  
  cat(sprintf("method,project,assert_count, confidence_interval, p-value, assert_mean, non_assert_mean, effect_size"))
  for(prj in unique(all$project)) {
     
    subProj = subset(all, project==prj)
    assert = subset(subProj, call_assert>0)
    nassert = subset(subProj, call_assert<=0)
    if(nrow(nassert) >= 5 & nrow(assert) >= 5) {
    
	   cat(sprintf("====== %s =======\n", prj))
	   indegree(assert, nassert)
	   outdegree(assert, nassert)
	   betw(assert, nassert)
	   hub(assert, nassert)
	   auth(assert, nassert)
    }
 }
}

#load('evr.RData')
#centralityAll(evr)


