{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Values.namePrefix $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}



{{- define "influxdb-excl-subs" -}}
    [influxdb.excluded-subscriptions]
    {{- range $idx, $item := . }}
        {{ $item.db }} = [{{ $item.retention | quote }}]
    {{- end }}
{{- end -}}