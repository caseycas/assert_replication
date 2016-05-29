# Data Layout

The Compressed folder contains .rar files for all data extracted with the gitcproc tool + those tables produced from the SQL queries aggregating and filtering this extracted data.

Accuracy Studies contains the instances used for the studies on bugs, changed non function chunks, and changed function chunks along with what they were evaluated with (Y for correct N for incorrect, Y? and N? for believed correct/incorrect/ and ?? for couldn't determine).

Csvs has the uncompressed csv files.  R_Inputs has the csv files created from the Java scripts and are the most processed data.  Running the appropriate R scripts with these inputs will reproduce raw forms of the tables and figures used in the replication paper.  Database_Tables is the storage location for the uncompressed version of the files in the Compressed folder.  Run the shell script unpackRarFiles.sh to place these files into Database_Tables.