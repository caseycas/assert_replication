INSERT INTO assert_july_2015_no_merge1.sha_diff(
            project, sha, language, file_name, is_test, method_name, assertion_add_old, 
            assertion_del_old, assertion_add_new, assertion_del_new, total_add_old, 
            total_del_old, total_add_new, total_del_new, is_bug_old, is_bug_new, 
            author, commit_date)
SELECT n.project, n.sha, n.language, n.file_name, n.is_test, n.method_name, o.assertion_add,
	o.assertion_del, n.assertion_add, n.assertion_del, o.total_add, o.total_del, 
	n.total_add, n.total_del, o.is_bug, n.is_bug, n.author, n.commit_date
FROM assert_july_2015_no_merge1.fc_everything_src_agg_fixed as n FULL JOIN 
	assert_july_2015_no_merge1.replication_filtered as o ON 
	n.project = o.project AND n.sha = o.sha AND n.file_name = o.file_name AND n.method_name = o.method_name
	AND n.author = o.author AND n.commit_date = o.commit_date;
