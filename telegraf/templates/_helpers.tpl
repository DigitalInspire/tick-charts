{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 24 -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Values.namePrefix $name | trunc 24 -}}
{{- end -}}

{{/*
  CUSTOM TEMPLATES: This section contains templates that make up the different parts of the telegraf configuration file.
  - global_tags section
  - agent section
*/}}

{{- define "global_tags" -}}
{{- if . -}}
[global_tags]
  {{- range $key, $val := . }}
      {{ $key }} = {{ $val | quote }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "agent" -}}
[agent]
{{- range $key, $value := . -}}
  {{- $tp := typeOf $value }}
  {{- if eq $tp "string"}}
      {{ $key }} = {{ $value | quote }}
  {{- end }}
  {{- if eq $tp "float64"}}
      {{ $key }} = {{ $value | int64 }}
  {{- end }}
  {{- if eq $tp "int"}}
      {{ $key }} = {{ $value | int64 }}
  {{- end }}
  {{- if eq $tp "bool"}}
      {{ $key }} = {{ $value }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "outputs" -}}
{{- range $outputIdx, $configObject := . -}}
{{- range $output, $config := . }}
    [[outputs.{{ $output }}]]
  {{- if $config }}
  {{- $tp := typeOf $config -}}
  {{- if eq $tp "map[string]interface {}" -}}
    {{- range $key, $value := $config -}}
      {{- $tp := typeOf $value }}
      {{- if eq $tp "string"}}
      {{ $key }} = {{ $value | quote }}
      {{- end }}
      {{- if eq $tp "float64"}}
      {{ $key }} = {{ $value | int64 }}
      {{- end }}
      {{- if eq $tp "int"}}
      {{ $key }} = {{ $value | int64 }}
      {{- end }}
      {{- if eq $tp "bool"}}
      {{ $key }} = {{ $value }}
      {{- end }}
      {{- if eq $tp "[]interface {}" }}
      {{- if eq $key "tagpass" }}
      [outputs.{{ $output }}.{{ $key }}]
      {{- range $i, $val := $value }}
        {{ $val.tag}} = [{{ $val.value | quote }}]
      {{end}}
      {{- else}}
      {{ $key }} = [
          {{- $numOut := len $value }}
          {{- $numOut := sub $numOut 1 }}
          {{- range $b, $val := $value }}
            {{- $i := int64 $b }}
            {{- if eq $i $numOut }}
        {{- $val | quote -}}
            {{- else }}
        {{- $val | quote -}},
            {{- end }}
          {{- end }}
      {{- "]" }}
      {{- end }}
    {{- end }}
    {{- end }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end -}}



{{/*
  This template handles the config.outputs of the values.yaml and is an improved template
  compared to the original outputs template.
  This template moves sub-tables at the end of a nested array table as telegraf cannot read
  key-value pairs of a nested array table if they are placed after a sub-table
  In case of the tagpass sub-table for influxdb outputs, this template solves this issue.
*/}}
{{- define "outputsv2" -}}
{{- range $outputIdx, $configObject := . -}}
{{- range $output, $config := . }}
    [[outputs.{{ $output }}]]
  {{- if $config }}
  {{- $tp := typeOf $config -}}
  {{- $idx := 0 }}
  {{- if eq $tp "map[string]interface {}" -}}
    {{- range $key, $value := $config -}}
      {{- $idx = add $idx 1}}
      {{- $tp := typeOf $value }}
      {{- if eq $tp "string"}}
      {{ $key }} = {{ $value | quote }}
      {{- end }}
      {{- if eq $tp "float64"}}
      {{ $key }} = {{ $value | int64 }}
      {{- end }}
      {{- if eq $tp "int"}}
      {{ $key }} = {{ $value | int64 }}
      {{- end }}
      {{- if eq $tp "bool"}}
      {{ $key }} = {{ $value }}
      {{- end }}
      {{- if eq $tp "[]interface {}" }}
      {{- if eq $key "tagexclude" }}       
      {{ $key }} = [
          {{- $numOut := len $value }}
          {{- $numOut := sub $numOut 1 }}
          {{- range $b, $val := $value }}
            {{- $i := int64 $b }}
            {{- if eq $i $numOut }}
        {{- $val | quote -}}
            {{- else }}
        {{- $val | quote -}},
            {{- end }}
          {{- end }}
      {{- "]" }}
    {{- end }}
    {{- end }}
    {{- if and (index $config "tagpass") (eq $idx (len $config))}}
      [outputs.{{ $output }}.tagpass]
      {{- range $i, $val := index $config "tagpass" }}
        {{ $val.tag}} = [{{ $val.value | quote }}]
      {{end}}
    {{- end }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end -}}





{{- define "inputs" -}}
{{- range $inputIdx, $configObject := . -}}
    {{- range $input, $config := . -}}
      
    [[inputs.{{- $input }}]]
    {{- if $config -}}
    {{- $tp := typeOf $config -}}
    {{- if eq $tp "map[string]interface {}" -}}
        {{- range $key, $value := $config -}}
          {{- $tp := typeOf $value -}}
          {{- if eq $tp "string" }}
      {{ $key }} = {{ $value | quote }}
          {{- end }}
          {{- if eq $tp "float64" }}
      {{ $key }} = {{ $value | int64 }}
          {{- end }}
          {{- if eq $tp "int" }}
      {{ $key }} = {{ $value | int64 }}
          {{- end }}
          {{- if eq $tp "bool" }}
      {{ $key }} = {{ $value }}
          {{- end }}
          {{- if eq $tp "[]interface {}" }}
      {{ $key }} = [
              {{- $numOut := len $value }}
              {{- $numOut := sub $numOut 1 }}
              {{- range $b, $val := $value }}
                {{- $i := int64 $b }}
                {{- $tp := typeOf $val }}
                {{- if eq $i $numOut }}
                  {{- if eq $tp "string" }}
        {{ $val | quote }}
                  {{- end }}
                  {{- if eq $tp "float64" }}
        {{ $val | int64 }}
                  {{- end }}
                {{- else }}
                  {{- if eq $tp "string" }}
        {{ $val | quote }},
                  {{- end}}
                  {{- if eq $tp "float64" }}
        {{ $val | int64 }},
                  {{- end }}
                {{- end }}
              {{- end }}
      ]
          {{- end }}
          {{- if eq $tp "map[string]interface {}" }}
      [[inputs.{{ $input }}.{{ $key }}]]
            {{- range $k, $v := $value }}
              {{- $tps := typeOf $v }}
              {{- if eq $tps "string" }}
        {{ $k }} = {{ $v }}
              {{- end }}
              {{- if eq $tps "[]interface {}"}}
        {{ $k }} = [
                {{- $numOut := len $value }}
                {{- $numOut := sub $numOut 1 }}
                {{- range $b, $val := $v }}
                  {{- $i := int64 $b }}
                  {{- if eq $i $numOut }}
            {{ $val | quote }}
                  {{- else }}
            {{ $val | quote }},
                  {{- end }}
                {{- end }}
        ]
              {{- end }}
              {{- if eq $tps "map[string]interface {}"}}
        [[inputs.{{ $input }}.{{ $key }}.{{ $k }}]]
                {{- range $foo, $bar := $v }}
            {{ $foo }} = {{ $bar | quote }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- end }}
    {{- end }}
    {{- end }}
    {{ end }}
{{- end }}
{{- end -}}
