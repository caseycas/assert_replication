SELECT count(distinct(author)) as file_count
  FROM assert_replication.fc_everything WHERE commit_date < '2014-7-20';