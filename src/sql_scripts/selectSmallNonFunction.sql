\copy (SELECT * FROM assert_july_2015_no_merge1.non_function WHERE total_add < 50 and total_del < 50) TO nonFunction.csv
