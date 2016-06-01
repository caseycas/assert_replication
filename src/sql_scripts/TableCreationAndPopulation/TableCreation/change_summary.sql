-- Table: assert_replication.change_summary

-- DROP TABLE assert_replication.change_summary;

CREATE TABLE assert_replication.change_summary
(
  project character varying(500) NOT NULL,
  sha text NOT NULL,
  author character varying(500),
  commit_date date,
  is_bug boolean,
  CONSTRAINT change_summary_pkey PRIMARY KEY (project, sha)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE assert_replication.change_summary
  OWNER TO postgres;
GRANT ALL ON TABLE assert_replication.change_summary TO postgres;