INSERT INTO assert_july_2015_no_merge1.change_summary_size(
            project, sha, author, commit_date, is_bug, total_add, total_delete)
SELECT project, sha, author, commit_date, is_bug, sum(total_add), sum(total_del) 
  FROM assert_july_2015_no_merge1.fc_everything_src GROUP BY project, sha, author, commit_date, is_bug;
