# Table Population

This folder shows how the tables not created from the gitcproc tool were created by sql
script from the change_summary and method_change_detail.

aggregationScriptReplication.sql - Aggregates fc_everything_src into fc_everything_src_agg which is used to the Java scripts
to produce the tables.

copyPhp-srcFunc.sql, copyPhp-srcNonFunc.sql, insertPhp-srcFunc.sql, insertPhp-srcNonFunc.sql, insertPhp-fcEverythng - These were used to copy data extracted from the php-src project under an older version of the tool.  The newer version hanged for reasons we could not determine. (See paper for some details.)

non_function_replication.sql - Applies a filter to method_change_detail to produce the non_function table.

repEverythingTable.sql - Creates fc_everything by combining method_change_detail with change_summary.

replicationFunctionFilter - Creates fc_everything_src by applying filter to a combined form of method_change_detail and change_summary.

