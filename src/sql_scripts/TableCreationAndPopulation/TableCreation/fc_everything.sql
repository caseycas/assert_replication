-- Table: assert_replication.fc_everything

-- DROP TABLE assert_replication.fc_everything;

CREATE TABLE assert_replication.fc_everything
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
ALTER TABLE assert_replication.fc_everything
  OWNER TO ccasal;
GRANT ALL ON TABLE assert_replication.fc_everything TO ccasal;
GRANT ALL ON TABLE assert_replication.fc_everything TO global_readers;