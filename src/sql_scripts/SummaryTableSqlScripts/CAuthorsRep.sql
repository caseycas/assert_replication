SELECT count(distinct(author))
  FROM assert_replication.fc_everything WHERE commit_date < '2014-7-20' and (language = 'c');
