SELECT count(DISTINCT(project))
  FROM assert_july_2015_no_merge1.method_change_detail WHERE language = 'c';

SELECT count(DISTINCT(project))
  FROM assert_july_2015_no_merge1.method_change_detail WHERE language = 'cpp' or language = 'cc' or language = 'cxx' or language = 'cp' or language = 'c++';

SELECT sum(method_count) FROM
(SELECT project, file_name, count(distinct(method_name)) as method_count
  FROM assert_july_2015_no_merge1.fc_everything_src_agg_fixed WHERE  commit_date < '2014-7-20' and (language = 'c') GROUP BY project, file_name) as subtable;

SELECT sum(method_count) FROM
(SELECT project, file_name, count(distinct(method_name)) as method_count
  FROM assert_july_2015_no_merge1.fc_everything_src_agg_fixed WHERE  commit_date < '2014-7-20' and (language = 'cpp' or language = 'cc' or language = 'cxx' or language = 'cp' or language = 'c++') GROUP BY project, file_name) as subtable;


SELECT sum(method_count) FROM
(SELECT project, file_name, count(distinct(method_name)) as method_count
  FROM assert_july_2015_no_merge1.fc_everything_src_agg_fixed WHERE language = 'c' and commit_date < '2014-7-20' and assertion_add > 0 GROUP BY project, file_name) as subtable;

SELECT sum(method_count) FROM
(SELECT project, file_name, count(distinct(method_name)) as method_count
  FROM assert_july_2015_no_merge1.fc_everything_src_agg_fixed WHERE  commit_date < '2014-7-20' and assertion_add > 0 and (language = 'cpp' or language = 'cc' or language = 'cxx' or language = 'cp' or language = 'c++') GROUP BY project, file_name) as subtable;


SELECT count(DISTINCT(sha))
  FROM assert_july_2015_no_merge1.change_summary_size WHERE commit_date < '2014-7-20' and total_add > 0;

SELECT count(DISTINCT(sha))
  FROM assert_july_2015_no_merge1.change_summary_size WHERE commit_date < '2014-7-20' and total_add > 0 and is_bug = True;
