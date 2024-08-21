---
title: 🤗 Stats
---

# Hub Growth

```sql hub_growth
WITH all_data AS (
  SELECT 
    DATE_TRUNC('month', CAST(createdAt AS DATE)) AS month, 
    'model' AS repo 
  FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/models/train/0000.parquet?download=true')
  
  UNION ALL
  
  SELECT 
    DATE_TRUNC('month', CAST(createdAt AS DATE)) AS month, 
    'dataset' AS repo 
  FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/datasets/train/0000.parquet?download=true')
  
  UNION ALL
  
  SELECT 
    DATE_TRUNC('month', CAST(createdAt AS DATE)) AS month, 
    'space' AS repo 
  FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/spaces/train/0000.parquet?download=true')
)
SELECT
  month,
  repo,
  COUNT(*) AS creations
FROM all_data
WHERE month < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY month, repo
ORDER BY month, repo
```

<AreaChart 
    data={hub_growth}
    x=month
    y=creations
    series=repo
/>


# Model Licenses

```sql model_license_ratio
  SELECT name, COUNT(*) as value
  FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/models/train/0000.parquet?download=true'),
   UNNEST(tags) AS t(name)
  WHERE name LIKE 'license:%'
  GROUP BY name;
```

<ECharts config={
    {
        tooltip: {
            formatter: '{b}: {c} ({d}%)'
        },
      series: [
        {
          type: 'pie',
          radius: ['40%', '70%'],
          data: [...model_license_ratio],
        }
      ]
      }
    }
/>

# Dataset SDKs

```sql dataset_license_ratio
  SELECT name, COUNT(*) as value
  FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/datasets/train/0000.parquet?download=true'),
  UNNEST(tags) AS t(name)
  WHERE name LIKE 'license:%'
  GROUP BY name;
```

<ECharts config={
    {
        tooltip: {
            formatter: '{b}: {c} ({d}%)'
        },
      series: [
        {
          type: 'pie',
          radius: ['40%', '70%'],
          data: [...dataset_license_ratio],
        }
      ]
      }
    }
/>

# Space SDKs

```sql space_sdk_ratio
  SELECT sdk as name, COUNT(*) as value
  FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/spaces/train/0000.parquet?download=true')
  GROUP BY name;
```


<ECharts config={
    {
        tooltip: {
            formatter: '{b}: {c} ({d}%)'
        },
      series: [
        {
          type: 'pie',
          radius: ['40%', '70%'],
          data: [...space_sdk_ratio],
        }
      ]
      }
    }
/>