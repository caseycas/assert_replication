SELECT count(DISTINCT(sha))
  FROM assert_replication.fc_everything_src_agg WHERE commit_date < '2014-7-20' AND assertion_add > 0 AND (language = 'c');
