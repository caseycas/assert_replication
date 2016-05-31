-- Table: assert_replication.method_change_detail

-- DROP TABLE assert_replication.method_change_detail;

CREATE TABLE assert_replication.method_change_detail
(
  project character varying(500),
  sha text,
  language character varying(500),
  file_name text,
  is_test boolean,
  method_name text,
  assert_adds integer,
  assert_dels integer,
  ut_a_adds integer,
  ut_a_dels integer,
  ut_ad_adds integer,
  ut_ad_dels integer,
  dcheck_adds integer,
  dcheck_dels integer,
  total_adds integer,
  total_dels integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE assert_replication.method_change_detail
  OWNER TO ccasal;
GRANT ALL ON TABLE assert_replication.method_change_detail TO ccasal;
