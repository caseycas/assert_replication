\copy (SELECT * FROM assert_july_2015_no_merge1.sha_diff WHERE total_add_old > 0 AND total_add_new > 0) TO 'diffTable.csv' WITH CSV;
