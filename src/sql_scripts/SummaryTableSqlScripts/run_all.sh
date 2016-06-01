#!/bin/sh

#  run_all.sh
#  
#
#  Created by Casey Casalnuovo on 5/31/16.
#

echo "Row 1 - Projects"
psql $1 < CProjectsRep.sql
psql $1 < CPPProjectsRep.sql
psql $1 < ProjectsRep.sql

echo "Row 2 - Authors"
psql $1 < CAuthorsRep.sql
psql $1 < CPPAuthorsRep.sql
psql $1 < AuthorRep.sql

echo "Row 3 - Files"
psql $1 < CFileCountRep.sql
psql $1 < CPPFileCountRep.sql
echo "Overall column is sum of these two."

echo "Row 4 - Functions"
psql $1 < CMethodRep.sql
psql $1 < CPPMethodRep.sql
echo "Overall column is sum of these two."

echo "Row 5 - Assert Functions"
psql $1 < CAssertMethodRep.sql
psql $1 < CPPAssertMethodRep.sql
echo "Overall column is sum of these two."

echo "Row 7 - Total Commits"
psql $1 < CCommitCountRep.sql
psql $1 < CPPCommitCountRep.sql
psql $1 < CommitCountRep.sql

echo "Row 7 - Assert Commits"
psql $1 < CAssertCommitsRep.sql
psql $1 < CPPAssertCommitsRep.sql
psql $1 < AssertCommitCountRep.sql

echo "Row 8 - Bugfixing Commits"
psql $1 < CBugCommitRep.sql
psql $1 < CPPBugCommitRep.sql
psql $1 < BugCommitCountRep.sql

echo "Row 9 - Bugfixing and Assert Commits"
psql $1 < CBugAssertCommitRep.sql
psql $1 < CPPBugAssertCommitRep.sql
psql $1 < AssertBugCommitCountRep.sql

echo "Row 10 - Total Function Changes"
psql $1 < replicationCFuncChanges.sql
psql $1 < replicationCPPFuncChanges.sql
echo "Overall column is sum of these two."

echo "Row 11 - Total Function Changes to Functions containing Asserts"
psql $1 < replicationCAssertChanges.sql
psql $1 < replicationCPPAssertChanges.sql
echo "Overall column is sum of these two."

echo "Row 12 - Total Functions Changes in Bugfixing Commits"
psql $1 < replicationCBugFuncChanges.sql
psql $1 < replicationCPPBugFuncChanges.sql
echo "Overall column is sum of these two."

echo "Row 13 - Total Functions Changes in Bugfixing Commits"
psql $1 < replicationCBugAssertFuncChanges.sql
psql $1 < replicationCPPBugAssertFuncChanges.sql
echo "Overall column is sum of these two."





