---
title: Model Tree Usage
---

### Base Model Tag Usage by Week (last 12 weeks)

```sql model_tree_usage
WITH model_tags AS (
  SELECT 
    DATE_TRUNC('week', CAST(createdAt AS TIMESTAMP)) AS week,
    id,
    UNNEST(tags) AS tag
    FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/models/train/0000.parquet?download=true')
    WHERE CAST(createdAt AS TIMESTAMP) >= DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '12 weeks'
  ),
  weekly_counts AS (
    SELECT 
      week,
      COUNT(DISTINCT id) AS total_models,
      COUNT(DISTINCT CASE WHEN LOWER(tag) LIKE '%base_model:%' THEN id END) AS base_model_count
    FROM model_tags
    GROUP BY week
  )
  SELECT 
    week,
    (base_model_count / total_models) AS percentage_model_with_base_model_tag
FROM weekly_counts
ORDER BY week DESC;
```


<BarChart 
    data={model_tree_usage}
    x=week
    y=percentage_model_with_base_model_tag
    yFmt=pct
    yTickMarks=true
    labels=true
    yMax=1
/>

## Low Hanging Fruit

Models that are `GGUF`, `MLC`, `AWQ`, `GPTQ`, or `ONNX` models that don't have the base model tag sorted by popularity.

```sql low_hanging_fruit_gguf
WITH gguf_models AS (
  SELECT 
    id,
    modelId,
    tags,
    downloads
  FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/models/train/0000.parquet?download=true')
  WHERE LOWER(modelId) LIKE '%gguf%'
     OR LOWER(modelId) LIKE '%mlc%'
     OR LOWER(modelId) LIKE '%awq%'
     OR LOWER(modelId) LIKE '%gptq%'
     OR LOWER(modelId) LIKE '%onnx%'
),
models_with_base_model_tag AS (
  SELECT 
    id
  FROM gguf_models,
    UNNEST(tags) AS tag
  WHERE LOWER(tag) LIKE '%base_model:%'
)
SELECT 
  gm.id,
  gm.modelId,
  gm.downloads
FROM gguf_models gm
LEFT JOIN models_with_base_model_tag bm ON gm.id = bm.id
WHERE bm.id IS NULL
ORDER BY gm.downloads DESC
LIMIT 10;
```

<DataTable data={low_hanging_fruit_gguf} search=true>
  <Column id="id" title="Model ID" />
  <Column id="downloads" title="Downloads" fmt="#,##0" />
</DataTable>