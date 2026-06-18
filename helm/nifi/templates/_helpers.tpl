{{/*
Expand the name of the chart.
*/}}
{{- define "nifi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nifi.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" $name .Values.region.name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nifi.labels" -}}
app.kubernetes.io/name: {{ include "nifi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/region: {{ .Values.region.name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
