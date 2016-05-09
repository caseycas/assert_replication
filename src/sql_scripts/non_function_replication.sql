INSERT INTO assert_replication.non_function(
            project, sha, language, file_name, is_test, method_name, assertion_add, 
            assertion_del, total_add, total_del, is_bug, author, commit_date)
SELECT m.project, m.sha, m.language, m.file_name, m.is_test, m.method_name, m.assert_adds + m.ut_a_adds + m.ut_ad_adds, 
       m.assert_dels + m.ut_a_dels + m.ut_ad_dels, m.total_adds, m.total_dels, c.is_bug, c.author, c.commit_date
  FROM assert_replication.method_change_detail as m INNER JOIN assert_replication.change_summary as c ON (m.project = c.project AND m.sha = c.sha)
 WHERE (m.method_name = 'NA' OR m.method_name LIKE '% %' OR m.method_name LIKE '%:' OR m.method_name LIKE '%class %' OR m.method_name LIKE '%;%' OR m.method_name = 'NO_FUNC_CONTEXT' OR m.method_name = 'GITCPROC_NON_FUNCTION' OR m.method_name LIKE '%{%' OR method_name LIKE '%"%') and is_test='f';
