\copy (SELECT * FROM assert_replication.non_function WHERE total_add < 50 and total_del < 50) TO nonFunction.csv
