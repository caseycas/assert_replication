SELECT project, file_name, method_name, min(commit_date) as first_assert_date
  into assert_july_2015_no_merge1.first_assert_date
  FROM assert_july_2015_no_merge1.fc_everything_src_agg_fixed
  where assertion_add > 0
  group by project, file_name, method_name;
