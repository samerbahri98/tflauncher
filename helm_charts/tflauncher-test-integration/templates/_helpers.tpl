{{/*
Expand the name of the chart.
*/}}
{{- define "tflauncher-test-integration.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tflauncher-test-integration.fullname" -}}
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
{{- define "tflauncher-test-integration.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tflauncher-test-integration.labels" -}}
helm.sh/chart: {{ include "tflauncher-test-integration.chart" . }}
{{ include "tflauncher-test-integration.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tflauncher-test-integration.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tflauncher-test-integration.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tflauncher-test-integration.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tflauncher-test-integration.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "tflauncher-test-integration.modules" -}}
{{ $gs := . }}
{{- range .Values.modules }}
{{ printf "%s.tar.gz" . }}: |-
    {{ $gs.Files.Get (printf "cache/%s.tgz" .) | b64enc }}
{{ printf "%s.tgz" . }}: |-
    {{ $gs.Files.Get (printf "cache/%s.tgz" .) | b64enc }}
{{ printf "%s.zip" . }}: |-
    {{ $gs.Files.Get (printf "cache/%s.zip" .) | b64enc }}
{{- end }}
{{- end }}
