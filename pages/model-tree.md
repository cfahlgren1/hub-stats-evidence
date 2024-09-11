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

## Top Models without Base Model Tag

#### Low Hanging Fruit: `GGUF`, `MLC`, `AWQ`, `GPTQ`, or `ONNX` models without Base Model Tag

```sql low_hanging_fruit
WITH model_derivatives AS (
  SELECT 
    id,
    tags,
    downloads,
    'https://huggingface.co/' || id AS hf_link
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
  FROM model_derivatives,
    UNNEST(tags) AS tag
  WHERE LOWER(tag) LIKE '%base_model:%'
)
SELECT 
  gm.hf_link,
  gm.downloads
FROM model_derivatives gm
LEFT JOIN models_with_base_model_tag bm ON gm.id = bm.id
WHERE bm.id IS NULL
ORDER BY gm.downloads DESC
LIMIT 25;
```

<DataTable data={low_hanging_fruit} search=true>
  <Column id="hf_link" contentType="link" title="Model ID" />
  <Column id="downloads" title="Downloads" fmt="#,##0" />
</DataTable>