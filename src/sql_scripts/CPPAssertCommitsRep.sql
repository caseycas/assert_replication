SELECT count(DISTINCT(sha))
  FROM assert_replication.fc_everything_src_agg WHERE commit_date < '2014-7-20' and assertion_add > 0 and (language = 'cpp' or language = 'cc' or language = 'cxx' or language = 'cp' or language = 'c++');
