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