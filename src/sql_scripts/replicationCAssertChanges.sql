SELECT count(*) FROM assert_replication.fc_everything_src WHERE commit_date < '2014-7-20' and (language = 'c') and assertion_add > 0;
