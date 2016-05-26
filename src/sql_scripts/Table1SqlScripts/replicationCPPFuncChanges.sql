SELECT count(*) FROM assert_replication.fc_everything_src WHERE commit_date < '2014-7-20' and (language = 'cpp' or language = 'cc' or language = 'cxx' or language = 'cp' or language = 'c++');
