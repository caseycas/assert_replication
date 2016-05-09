SELECT agg.project, agg.sha, agg.language, agg.file_name, agg.is_test, agg.method_name, agg.assertion_add,
  agg.assertion_del, agg.total_add, agg.total_del, agg.is_bug, agg.author, agg.commit_date, date.first_assert_date
  into assert_july_2015_no_merge1.fc_everything_after_1st_assert
  FROM assert_july_2015_no_merge1.fc_everything_src_agg_fixed as agg INNER JOIN assert_july_2015_no_merge1.first_assert_date as date
  ON agg.project = date.project AND agg.file_name = date.file_name AND agg.method_name = date.method_name 
  where agg.commit_date > date.first_assert_date;
