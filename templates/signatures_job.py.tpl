import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import pyspark.sql.functions as func

## @params: [TempDir, JOB_NAME]
args = getResolvedOptions(sys.argv, ['TempDir','JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "default_staging", table_name = "signatures", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "default_staging", table_name = "signatures", transformation_ctx = "datasource0")


########### Is this what we want????
#latestpartition = datasource0.toDF().agg(func.max("partition_0").alias("last_partition")).collect()[0]["last_partition"]
latestpartition = '20200116'
datasource1 = glueContext.create_dynamic_frame.from_catalog(
    database = "default_staging",
    table_name = "signatures",
    push_down_predicate = "(partition_0 == '{latestpartition}')",
    transformation_ctx = "datasource1")
##############




## @type: ApplyMapping
## @args: [mapping = [("id", "long", "id", "long"), ("petition_id", "long", "petition_id", "long"), ("email", "string", "email", "string"), ("first_name", "string", "first_name", "string"), ("last_name", "string", "last_name", "string"), ("phone_number", "string", "phone_number", "string"), ("postcode", "string", "postcode", "string"), ("created_at", "string", "created_at", "string"), ("join_organisation", "string", "join_organisation", "string"), ("deleted_at", "string", "deleted_at", "string"), ("unsubscribe_at", "string", "unsubscribe_at", "string"), ("external_constituent_id", "long", "external_constituent_id", "long"), ("member_id", "long", "member_id", "long"), ("additional_fields", "string", "additional_fields", "string"), ("cached_organisation_slug", "string", "cached_organisation_slug", "string"), ("source", "string", "source", "string"), ("join_group", "string", "join_group", "string"), ("external_id", "long", "external_id", "long"), ("new_member", "string", "new_member", "string"), ("external_action_id", "string", "external_action_id", "string"), ("locale", "string", "locale", "string"), ("obfuscated_bsd_cons_id", "string", "obfuscated_bsd_cons_id", "string"), ("bucket", "string", "bucket", "string"), ("country", "string", "country", "string"), ("updated_at", "string", "updated_at", "string"), ("user_ip", "string", "user_ip", "string"), ("confirmation_token", "string", "confirmation_token", "string"), ("confirmed_at", "string", "confirmed_at", "string"), ("confirmation_sent_at", "string", "confirmation_sent_at", "string"), ("last_signed_at", "string", "last_signed_at", "string"), ("join_list_suppressed", "string", "join_list_suppressed", "string"), ("old_daisy_chain_used", "string", "old_daisy_chain_used", "string"), ("bsd_ab_test_cons_group_id", "string", "bsd_ab_test_cons_group_id", "string"), ("from_embed", "string", "from_embed", "string"), ("user_agent", "string", "user_agent", "string"), ("confirmed_reason", "string", "confirmed_reason", "string"), ("synced_to_crm_at", "string", "synced_to_crm_at", "string"), ("daisy_chain_experiment_slug", "string", "daisy_chain_experiment_slug", "string"), ("eu_data_processing_consent", "string", "eu_data_processing_consent", "string"), ("from_one_click", "string", "from_one_click", "string"), ("consent_content_version_id", "string", "consent_content_version_id", "string"), ("daisy_chain_id_used", "string", "daisy_chain_id_used", "string"), ("email_opt_in_type_id", "long", "email_opt_in_type_id", "long"), ("facebook_id", "string", "facebook_id", "string"), ("utm_params", "string", "utm_params", "string"), ("postcode_id", "long", "postcode_id", "long"), ("referring_share_click_id", "string", "referring_share_click_id", "string"), ("signon_user_list_map_user_id", "string", "signon_user_list_map_user_id", "string"), ("signon_user_list_map_list_id", "string", "signon_user_list_map_list_id", "string"), ("partition_0", "string", "partition_0", "string")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource1]
applymapping1 = ApplyMapping.apply(frame = datasource1, mappings = [("id", "long", "id", "long"), ("petition_id", "long", "petition_id", "long"), ("email", "string", "email", "string"), ("first_name", "string", "first_name", "string"), ("last_name", "string", "last_name", "string"), ("phone_number", "string", "phone_number", "string"), ("postcode", "string", "postcode", "string"), ("created_at", "string", "created_at", "string"), ("join_organisation", "string", "join_organisation", "string"), ("deleted_at", "string", "deleted_at", "string"), ("unsubscribe_at", "string", "unsubscribe_at", "string"), ("external_constituent_id", "long", "external_constituent_id", "long"), ("member_id", "long", "member_id", "long"), ("additional_fields", "string", "additional_fields", "string"), ("cached_organisation_slug", "string", "cached_organisation_slug", "string"), ("source", "string", "source", "string"), ("join_group", "string", "join_group", "string"), ("external_id", "long", "external_id", "long"), ("new_member", "string", "new_member", "string"), ("external_action_id", "string", "external_action_id", "string"), ("locale", "string", "locale", "string"), ("obfuscated_bsd_cons_id", "string", "obfuscated_bsd_cons_id", "string"), ("bucket", "string", "bucket", "string"), ("country", "string", "country", "string"), ("updated_at", "string", "updated_at", "string"), ("user_ip", "string", "user_ip", "string"), ("confirmation_token", "string", "confirmation_token", "string"), ("confirmed_at", "string", "confirmed_at", "string"), ("confirmation_sent_at", "string", "confirmation_sent_at", "string"), ("last_signed_at", "string", "last_signed_at", "string"), ("join_list_suppressed", "string", "join_list_suppressed", "string"), ("old_daisy_chain_used", "string", "old_daisy_chain_used", "string"), ("bsd_ab_test_cons_group_id", "string", "bsd_ab_test_cons_group_id", "string"), ("from_embed", "string", "from_embed", "string"), ("user_agent", "string", "user_agent", "string"), ("confirmed_reason", "string", "confirmed_reason", "string"), ("synced_to_crm_at", "string", "synced_to_crm_at", "string"), ("daisy_chain_experiment_slug", "string", "daisy_chain_experiment_slug", "string"), ("eu_data_processing_consent", "string", "eu_data_processing_consent", "string"), ("from_one_click", "string", "from_one_click", "string"), ("consent_content_version_id", "string", "consent_content_version_id", "string"), ("daisy_chain_id_used", "string", "daisy_chain_id_used", "string"), ("email_opt_in_type_id", "long", "email_opt_in_type_id", "long"), ("facebook_id", "string", "facebook_id", "string"), ("utm_params", "string", "utm_params", "string"), ("postcode_id", "long", "postcode_id", "long"), ("referring_share_click_id", "string", "referring_share_click_id", "string"), ("signon_user_list_map_user_id", "string", "signon_user_list_map_user_id", "string"), ("signon_user_list_map_list_id", "string", "signon_user_list_map_list_id", "string"), ("partition_0", "string", "partition_0", "string")], transformation_ctx = "applymapping1")
## @type: ResolveChoice
## @args: [choice = "make_cols", transformation_ctx = "resolvechoice2"]
## @return: resolvechoice2
## @inputs: [frame = applymapping1]
resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_cols", transformation_ctx = "resolvechoice2")
## @type: DropNullFields
## @args: [transformation_ctx = "dropnullfields3"]
## @return: dropnullfields3
## @inputs: [frame = resolvechoice2]
dropnullfields3 = DropNullFields.apply(frame = resolvechoice2, transformation_ctx = "dropnullfields3")
## @type: DataSink
## @args: [catalog_connection = "moveon_data_sync_redshift_test", connection_options = {"dbtable": "signatures", "database": "default_staging"}, redshift_tmp_dir = TempDir, transformation_ctx = "datasink4"]
## @return: datasink4
## @inputs: [frame = dropnullfields3]
datasink4 = glueContext.write_dynamic_frame.from_jdbc_conf(frame = dropnullfields3, catalog_connection = "moveon_data_sync_redshift_test", connection_options = {"preactions": "truncate table signatures;", "dbtable": "signatures", "database": "default_staging"}, redshift_tmp_dir = args["TempDir"], transformation_ctx = "datasink4")
job.commit()
