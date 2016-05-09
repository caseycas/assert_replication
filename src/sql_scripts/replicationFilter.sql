INSERT INTO assert_july_2015_no_merge1.replication_filtered(
            project, sha, language, file_name, is_test, method_name, assertion_add, 
            assertion_del, total_add, total_del, is_bug, author, commit_date)
SELECT project, sha, language, file_name, is_test, method_name, assertion_add, 
            assertion_del, total_add, total_del, is_bug, author, commit_date 
            FROM assert_july_2015_no_merge1.replication_table as m WHERE
m.method_name <> 'NA' AND m.method_name NOT LIKE '% %' AND m.method_name <> ''
AND m.method_name NOT LIKE '%:' AND m.method_name NOT LIKE '%class %' 
AND m.method_name NOT LIKE '%;%'  AND m.method_name <> 'Mock_Function_For_Asserts' 
AND m.method_name NOT LIKE '%{%' AND m.method_name NOT LIKE '%"%'
AND m.total_add >= m.assertion_add AND m.total_del >= m.assertion_del AND m.is_test='f'; 

