{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "provisionFullname" -}}
{{- printf "%s-provision" (include "fullname" .) -}}
{{- end -}}

{{- define "metricTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_metrics_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_metrics
{{- end -}}
{{- end -}}

{{- define "auditTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_audits_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_audits
{{- end -}}
{{- end -}}

{{- define "processorTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_processors_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_processors
{{- end -}}
{{- end -}}

{{- define "alertTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_alerts_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_alerts
{{- end -}}
{{- end -}}

{{- define "profileTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_profiles_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_profiles
{{- end -}}
{{- end -}}

{{- define "alertSettingTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_alert_settings_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_alert_settings
{{- end -}}
{{- end -}}

{{- define "clusterTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_cluster_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_cluster
{{- end -}}
{{- end -}}

{{- define "lsqlTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_lsql_storage_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_lsql_storage
{{- end -}}
{{- end -}}

{{- define "metadataTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_topics_metadata_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_topics_metadata
{{- end -}}
{{- end -}}

{{- define "topologyTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
__topology_{{ .Values.lenses.topics.suffix }}
{{- else -}}
__topology
{{- end -}}
{{- end -}}

{{- define "externalMetricsTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
__topology__metrics_{{ .Values.lenses.topics.suffix }}
{{- else -}}
__topology__metrics
{{- end -}}
{{- end -}}

{{- define "connectorsTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_connectors_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_processors
{{- end -}}
{{- end -}}

{{- define "zookeepers" -}}
[
  {{- range $zkIndex, $zk := .Values.lenses.zookeepers.hosts -}}
  {{- if $zkIndex }},{{ end }}
  {
    url: "{{$zk.host}}:{{$zk.port}}"
  {{- if $zk.metrics -}},
    metrics: {
      {{- if $zk.metrics.url }}
      url: {{$zk.metrics.url | quote}},
      {{- else if eq $zk.metrics.type "JMX" }}
      url: "{{$zk.host}}:{{$zk.metrics.port}}",
      {{- else }}
      url: "{{$zk.protocol}}://{{$zk.host}}:{{$zk.metrics.port}}",
      {{- end }}
      type: "{{$zk.metrics.type}}",
      ssl: {{default false $zk.metrics.ssl}},
      {{- if $zk.metrics.username -}}
      user: {{$zk.metrics.username | quote}},
      {{- end }}
      {{- if $zk.metrics.password -}}
      password: {{$zk.metrics.password | quote}},
      {{- end }}
    }{{- end}}
  }
{{- end}}
]
{{- end -}}

{{- define "alertPlugins" -}}
{{- if .Values.lenses.alerts.plugins -}}
[
  {{ range $index, $element := .Values.lenses.alerts.plugins }}
  {{- if not $index -}}{class: "{{$element.class}}", config: {{$element.config}}}
  {{- else}},{class: "{{$element.class}}", config: {{$element.config}}}{{- end }}
  {{- end }}
]
{{- end -}}
{{- end -}}

{{- define "kerberos" -}}
{{- if .Values.lenses.security.kerberos.enabled }}
lenses.security.kerberos.service.principal={{ .Values.lenses.security.kerberos.servicePrincipal | quote }}
lenses.security.kerberos.keytab=/mnt/secrets/lenses.keytab
lenses.security.kerberos.debug={{ .Values.lenses.security.kerberos.debug | quote }}
{{end -}}
{{- end -}}

{{- define "lensesAppendConf" -}}
{{- if .Values.lenses.storage.postgres.enabled }}
lenses.storage.postgres.host={{ required "PostgreSQL 'host' value is mandatory" .Values.lenses.storage.postgres.host | quote }}
lenses.storage.postgres.database={{ required "PostgreSQL 'database' value is mandatory" .Values.lenses.storage.postgres.database | quote }}
{{- if not (eq (default "not-external" .Values.lenses.storage.postgres.username) "external") }}
lenses.storage.postgres.username={{ required "PostgreSQL 'username' value is mandatory" .Values.lenses.storage.postgres.username | quote }}
{{- end }}
{{- if .Values.lenses.storage.postgres.port }}
lenses.storage.postgres.port={{  .Values.lenses.storage.postgres.port | quote }}
{{- end }}
{{- if .Values.lenses.storage.postgres.schema }}
lenses.storage.postgres.schema={{ .Values.lenses.storage.postgres.schema | quote }}
{{- end }}
{{- end }}
{{ default "" .Values.lenses.append.conf }}
{{- end -}}

{{- define "securityConf" -}}
{{- if .Values.lenses.security.defaultUser }}
{{- if not (eq (default "not-external" .Values.lenses.security.defaultUser.username) "external") }}
lenses.security.user={{ required "'username' for Lenses defaultUser is mandatory if 'password' is set" .Values.lenses.security.defaultUser.username | quote }}
{{- end -}}
{{- if not (eq (default "not-external" .Values.lenses.security.defaultUser.password) "external") }}
lenses.security.password={{ required "'password' for Lenses defaultUser is mandatory if 'username' is set" .Values.lenses.security.defaultUser.password | quote }}
{{- end -}}
{{- end -}}
{{- if .Values.lenses.security.ldap.enabled }}
lenses.security.ldap.url={{ .Values.lenses.security.ldap.url | quote }}
lenses.security.ldap.base={{ .Values.lenses.security.ldap.base | quote }}
lenses.security.ldap.user={{ .Values.lenses.security.ldap.user | quote }}
{{- if not (eq (default "not-external" .Values.lenses.security.ldap.password) "external") }}
lenses.security.ldap.password={{ .Values.lenses.security.ldap.password | quote }}
{{- end }}
lenses.security.ldap.filter={{ .Values.lenses.security.ldap.filter | quote }}
lenses.security.ldap.plugin.class={{ .Values.lenses.security.ldap.plugin.class | quote }}
lenses.security.ldap.plugin.memberof.key={{ .Values.lenses.security.ldap.plugin.memberofKey | quote }}
lenses.security.ldap.plugin.group.extract.regex={{ .Values.lenses.security.ldap.plugin.groupExtractRegex | quote }}
lenses.security.ldap.plugin.person.name.key={{ .Values.lenses.security.ldap.plugin.personNameKey | quote }}
{{- end -}}
{{- if .Values.lenses.security.saml.enabled }}
lenses.security.saml.base.url={{ .Values.lenses.security.saml.baseUrl | quote }}
lenses.security.saml.idp.provider={{ .Values.lenses.security.saml.provider | quote }}
lenses.security.saml.idp.metadata.file="/mnt/secrets/saml.idp.xml"
lenses.security.saml.keystore.location="/mnt/secrets/saml.keystore.jks"
lenses.security.saml.keystore.password={{ .Values.lenses.security.saml.keyStorePassword | quote }}
{{- if .Values.lenses.security.saml.keyAlias }}
lenses.security.saml.key.alias={{ .Values.lenses.security.saml.keyAlias | quote }}
{{- end }}
lenses.security.saml.key.password={{ .Values.lenses.security.saml.keyPassword | quote }}
{{- end }}
{{- if .Values.lenses.security.kerberos.enabled -}}
{{ include "kerberos" .}}
{{- end -}}
{{- if and .Values.lenses.storage.postgres.enabled .Values.lenses.storage.postgres.password }}
{{- if not (eq (default "not-external" .Values.lenses.storage.postgres.password) "external") }}
lenses.storage.postgres.password={{ required "PostgreSQL 'password' value is mandatory" .Values.lenses.storage.postgres.password | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "lensesOpts" -}}
{{- if .Values.lenses.opts.keyStoreFileData }}-Djavax.net.ssl.keyStore="/mnt/secrets/lenses.opts.keystore.jks" {{ end -}}
{{- if .Values.lenses.opts.keyStorePassword }}-Djavax.net.ssl.keyStorePassword="${CLIENT_OPTS_KEYSTORE_PASSWORD}" {{ end -}}
{{- if .Values.lenses.opts.trustStoreFileData }}-Djavax.net.ssl.trustStore="/mnt/secrets/lenses.opts.truststore.jks" {{ end -}}
{{- if .Values.lenses.opts.trustStorePassword }}-Djavax.net.ssl.trustStorePassword="${CLIENT_OPTS_TRUSTSTORE_PASSWORD}" {{ end -}}
{{- if .Values.lenses.logbackXml }}-Dlogback.configurationFile="file:{{ .Values.lenses.logbackXml}}" {{ end -}}
{{- if .Values.lenses.lensesOpts }}{{- .Values.lenses.lensesOpts }}{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Fail the deployment when deprecated keys are stil used
*/}}
{{- define "checkForDeprecatedKeys" -}}
{{- $errorMessage := "values should be replaced from provision.yaml content" -}}
{{- if .Values.lenses.license}}
{{- required (printf ".Values.lenses.license %s" $errorMessage) nil}}
{{- end}}
{{- if .Values.lenses.licenseUrl}}
{{- required (printf ".Values.lenses.licenseUrl %s" $errorMessage) nil}}
{{- end}}
{{- if .Values.lenses.kafka}}
{{- required (printf ".Values.lenses.kafka %s" $errorMessage) nil}}
{{- end}}
{{- if .Values.lenses.schemaRegistries}}
{{- required (printf ".Values.lenses.schemaRegistries %s" $errorMessage) nil}}
{{- end}}
{{- if .Values.lenses.connectClusters}}
{{- required (printf ".Values.lenses.connectClusters %s" $errorMessage) nil}}
{{- end}}
{{- end -}}