\copy (SELECT * from assert_july_2015_no_merge1.method_change_detail WHERE (assertion_add > 0 or assertion_del > 0)) TO "rawAsserts.csv" CSV;
