INSERT INTO assert_july_2015_no_merge1.fc_everything_src_agg(
            project, sha, language, file_name, is_test, method_name, assertion_add, 
            assertion_del, total_add, total_del, is_bug, author, commit_date)
SELECT project, sha, language, file_name, is_test, method_name, sum(assertion_add), sum(assertion_del), sum(total_add), sum(total_del), is_bug, author, commit_date  
  FROM assert_july_2015_no_merge1.fc_everything_src GROUP BY project, sha, language, file_name, is_test, method_name,is_bug, author, commit_date;
