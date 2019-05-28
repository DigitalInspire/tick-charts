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



{{/*
Iterate over all users to create them with curl.
See post-install-create-users.yaml (K8s Job) for more information.
*/}}
{{- define "users" -}}
{{ $len := len . }}
{{- if gt $len 0 }}
{{- range $userIdx, $userObject := . -}}
    CREATE USER \"{{ $userObject.username }}\" WITH PASSWORD '{{ $userObject.password }}' {{ $userObject.privileges }};
    {{- end }}
{{- end }}    
{{- end -}}