INSERT INTO assert_july_2015_no_merge1.fc_everything_before_1st_assert_agg(
            project, language, file_name, is_test, method_name, assertion_add, 
            assertion_del, total_add, total_del, bug_count, author_count)
SELECT project, language, file_name, is_test, method_name, sum(assertion_add),
sum(assertion_del), sum(total_add), sum(total_del), sum(CASE is_bug WHEN TRUE THEN 1 ELSE 0 END),
count(DISTINCT(author)) FROM assert_july_2015_no_merge1.fc_everything_before_1st_assert
GROUP BY project, language, file_name, is_test, method_name;
