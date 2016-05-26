SELECT count(DISTINCT(sha))
  FROM assert_replication.fc_everything_src_agg WHERE commit_date < '2014-7-20' and is_bug = True AND (language = 'c');
