SELECT sum(file_count) FROM
(SELECT project, count(distinct(file_name)) as file_count
  FROM assert_replication.fc_everything WHERE  commit_date < '2014-7-20' and (language = 'c') GROUP BY project) as subtable;
