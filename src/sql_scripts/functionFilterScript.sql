INSERT INTO assert_july_2015_no_merge1.fc_everything_src(
            project, sha, language, file_name, is_test, method_name, assertion_add, 
            assertion_del, total_add, total_del, is_bug, author, commit_date)
SELECT m.project, m.sha, m.language, m.file_name, m.is_test, m.method_name, m.assertion_add, 
       m.assertion_del, m.total_add, m.total_del, c.is_bug, c.author, c.commit_date
  FROM assert_july_2015_no_merge1.method_change_detail as m INNER JOIN assert_july_2015_no_merge1.change_summary as c ON (m.project = c.project AND m.sha = c.sha)
 WHERE m.method_name <> 'NA' AND m.method_name NOT LIKE '% %' AND m.method_name NOT LIKE '%:' AND m.method_name NOT LIKE '%class %' AND m.method_name NOT LIKE '%;%'  AND m.method_name <> 'Mock_Function_For_Asserts' AND m.method_name NOT LIKE '%{%' AND is_test='f'; 
