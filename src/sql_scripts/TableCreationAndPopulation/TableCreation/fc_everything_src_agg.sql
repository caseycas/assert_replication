-- Table: assert_replication.fc_everything_src_agg

-- DROP TABLE assert_replication.fc_everything_src_agg;

CREATE TABLE assert_replication.fc_everything_src_agg
(
  project character varying(500) NOT NULL,
  sha text NOT NULL,
  language character varying(500),
  file_name text NOT NULL,
  is_test boolean,
  method_name text NOT NULL,
  assertion_add integer,
  assertion_del integer,
  total_add integer,
  total_del integer,
  is_bug boolean,
  author character varying(500) NOT NULL,
  commit_date date,
  CONSTRAINT pkey PRIMARY KEY (project, sha, file_name, method_name, author)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE assert_replication.fc_everything_src_agg
  OWNER TO ccasal;
GRANT ALL ON TABLE assert_replication.fc_everything_src_agg TO ccasal;
