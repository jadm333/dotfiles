; extends

; Inject SQL into jinja content nodes (for dbt files)
((content) @injection.content
  (#set! injection.language "sql")
  (#set! injection.combined))
