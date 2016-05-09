INSERT INTO assert_july_2015_no_merge1.fc_everything_src_agg_fixed(
            project, sha, language, file_name, is_test, method_name, assertion_add, 
            assertion_del, total_add, total_del, is_bug, author, commit_date)
SELECT project, sha, language, file_name, is_test, method_name, assertion_add, 
            assertion_del, total_add, total_del, is_bug, author, commit_date 
            FROM assert_july_2015_no_merge1.fc_everything_src_agg
            WHERE method_name NOT LIKE '%"%' AND total_add >= assertion_add AND total_del >= assertion_del;
