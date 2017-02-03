unique template metaconfig/logstash/forwarder;

include 'metaconfig/logstash/version';
include format("metaconfig/logstash/formatter_%s", METACONFIG_LOGSTASH_VERSION);
