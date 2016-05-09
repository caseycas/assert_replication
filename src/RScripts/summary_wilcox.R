require('lsr')

indegree<-function(assert, nassert){

  #Indegree: 

  wl = wilcox.test(assert$in_degree, nassert$in_degree,alternative = 'l')
  wg = wilcox.test(assert$in_degree, nassert$in_degree,alternative = 'g')
  
  cat(sprintf("in_degree,%s,%d,%s,%g,%s,%g\n", 
        unique(assert$project)[1], nrow(assert), 
        wl$alternative, wl$p.value, 
        wg$alternative, wg$p.value))
  
}

outdegree<-function(assert, nassert){
  
  #outdegree: 
  wl = wilcox.test(assert$out_degree, nassert$out_degree,alternative = 'l')
  wg = wilcox.test(assert$out_degree, nassert$out_degree,alternative = 'g')
  
  cat(sprintf("out_degree,%s,%d,%s,%g,%s,%g\n", 
              unique(assert$project)[1], nrow(assert), 
              wl$alternative, wl$p.value, 
              wg$alternative, wg$p.value))

  
}

betw<-function(assert, nassert){

  #betweenness:   
  wl = wilcox.test(assert$betweenness, nassert$betweenness,alternative = 'l')
  wg = wilcox.test(assert$betweenness, nassert$betweenness,alternative = 'g')
  
  cat(sprintf("betweenness,%s,%d,%s,%g,%s,%g\n", 
              unique(assert$project)[1], nrow(assert), 
              wl$alternative, wl$p.value, 
              wg$alternative, wg$p.value))

}

hub<-function(assert, nassert) {

  #hub: 
  wl = wilcox.test(assert$hub, nassert$hub,alternative = 'l')
  wg = wilcox.test(assert$hub, nassert$hub,alternative = 'g')
  
  #cat(sprintf("hub,%s,%d,%s,%g,%s,%g\n", 
  cat(sprintf("%s,%d,%g\n", 
              unique(assert$project)[1], nrow(assert), 
          #    wl$alternative, p.adjust(wl$p.value), 
          #    wg$alternative, 
              p.adjust(wg$p.value,method = 'BH'))
  )
  
}

auth<-function(assert, nassert) {
  #auth:   
  wl = wilcox.test(assert$auth, nassert$auth,alternative = 'l')
  wg = wilcox.test(assert$auth, nassert$auth,alternative = 'g')
  
  cat(sprintf("auth,%s,%d,%s,%g,%s,%g\n", 
              unique(assert$project)[1], nrow(assert), 
              wl$alternative, wl$p.value, 
              wg$alternative, wg$p.value))
 
}


centralityAll<-function(all) {
 
  all$out_degree = log(all$out_degree / (all$LOC + 0.5))
  all$hub = log(all$hub / (all$LOC + 0.5))
  all$betweenness = log(all$betweenness / (all$LOC + 0.5))
  all$in_degree  = log(all$in_degree)
  all$auth  = log(all$auth)


  cat(sprintf("method,project,assert_count, confidence_interval, p-value, assert_mean, non_assert_mean, effect_size"))
  for(prj in unique(all$project)) {
     
    subProj = subset(all, project==prj)
    assert = subset(subProj, call_assert>0)
    nassert = subset(subProj, call_assert<=0)
    if(nrow(nassert) >= 1 & nrow(assert) >= 1) {
    
	   #cat(sprintf("====== %s =======\n", prj))
	   #indegree(assert, nassert)
	   #outdegree(assert, nassert)
	   #betw(assert, nassert)
	   hub(assert, nassert)
	   #auth(assert, nassert)
    }
 }
}

#load('evr.RData')
#centralityAll(evr)


