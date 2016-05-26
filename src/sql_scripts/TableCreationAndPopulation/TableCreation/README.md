# Table Creation
This scripts create the the database tables used to store data extracted from the log files.
They are named after the tables they create.  You will need to create a schema in your database
called assert replication.  Also, you will need to configure the GRANT options at the bottom
of each to match the users in your database.

Table Summary:

method_change_detail - This are the raw values extracted from the logs via the tool at
github.com/caseycas/gitcproc. They are listed for each extracted chunk change, functional
or non_functional.

change_summary - This table has an entry for each commit in each project, providing the
meta information for method change_detail.

non_function - These are filtered chunk changes from method_change_detail which, based
on a filter, did not see to match function names.

fc_everything_src - These are filtered chunk changes from method_change_detail which,
based on a filter, seemed to be function names.

fc_everything_src_agg - This is a aggregated version of fc_everything_src.  In case
multiple changes to a function were recorded in the log for a commit, this guarantees
a unique marker for each (commit, project, file, function) change.

fc_everything - A combined form of the non_function and fc_everything_src.