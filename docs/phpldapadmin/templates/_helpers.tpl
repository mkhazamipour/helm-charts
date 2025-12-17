{{/*
Expand the name of the chart.
*/}}
{{- define "phpldapadmin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "phpldapadmin.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "phpldapadmin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "phpldapadmin.labels" -}}
helm.sh/chart: {{ include "phpldapadmin.chart" . }}
{{ include "phpldapadmin.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "phpldapadmin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "phpldapadmin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "phpldapadmin.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "phpldapadmin.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the LDAP connection URL for display purposes
*/}}
{{- define "phpldapadmin.ldapUrl" -}}
{{- printf "ldap://%s:%s" .Values.env.ldapHost .Values.env.ldapPort }}
{{- end }}

{{/*
Check if secret is properly configured
*/}}
{{- define "phpldapadmin.secretConfigured" -}}
{{- if .Values.secret.existingSecret }}
{{- printf "true" }}
{{- else }}
{{- printf "false" }}
{{- end }}
{{- end }}

{{/*
Generate environment variables as a helper
*/}}
{{- define "phpldapadmin.env" -}}
- name: APP_URL
  value: {{ .Values.env.appUrl | quote }}
- name: LDAP_HOST
  value: {{ .Values.env.ldapHost | quote }}
- name: LDAP_BASE_DN
  value: {{ .Values.env.ldapBaseDn | quote }}
- name: LDAP_USERNAME
  value: {{ .Values.env.ldapUsername | quote }}
{{- if .Values.secret.existingSecret }}
- name: LDAP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secret.existingSecret }}
      key: {{ .Values.secret.ldapPasswordKey }}
{{- end }}
- name: LDAP_LOGIN_ATTR
  value: {{ .Values.env.ldapLoginAttr | quote }}
- name: LDAP_PORT
  value: {{ .Values.env.ldapPort | quote }}
- name: LDAP_NAME
  value: {{ .Values.env.ldapName | quote }}
{{- end }}

{{/*
Generate standard annotations for all resources
*/}}
{{- define "phpldapadmin.annotations" -}}
helm.sh/chart: {{ include "phpldapadmin.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/created-by: "Helm"
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Validate required values
*/}}
{{- define "phpldapadmin.validateValues" -}}
{{- if not .Values.env.ldapHost }}
{{- fail "env.ldapHost is required" }}
{{- end }}
{{- if not .Values.env.ldapBaseDn }}
{{- fail "env.ldapBaseDn is required" }}
{{- end }}
{{- if not .Values.env.ldapUsername }}
{{- fail "env.ldapUsername is required" }}
{{- end }}
{{- end }}
