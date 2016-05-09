\copy (SELECT * FROM assert_replication.fc_everything_src WHERE total_add < 50 and total_del < 50 and (assertion_add > 0 or assertion_del > 0)) TO smallAssertFunctions.csv
