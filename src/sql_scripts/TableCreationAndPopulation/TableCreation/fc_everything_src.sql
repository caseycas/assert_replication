-- Table: assert_replication.fc_everything_src

-- DROP TABLE assert_replication.fc_everything_src;

CREATE TABLE assert_replication.fc_everything_src
(
  project character varying(500),
  sha text,
  language character varying(500),
  file_name text,
  is_test boolean,
  method_name text,
  assertion_add integer,
  assertion_del integer,
  total_add integer,
  total_del integer,
  is_bug boolean,
  author character varying(500),
  commit_date date
)
WITH (
  OIDS=FALSE
);
ALTER TABLE assert_replication.fc_everything_src
  OWNER TO ccasal;
GRANT ALL ON TABLE assert_replication.fc_everything_src TO ccasal;
GRANT ALL ON TABLE assert_replication.fc_everything_src TO global_readers;
