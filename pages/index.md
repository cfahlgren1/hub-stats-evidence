---
title: 🤗 Stats
---

# Hub Growth

Models, Datasets, Spaces created per month

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
WHERE month < DATE_TRUNC('month', CURRENT_DATE())
GROUP BY month, repo
ORDER BY month, repo
```

<BarChart 
    data={hub_growth}
    x=month
    y=creations
      colorPalette={[
        '#cf0d06',
        '#eb5752',
        '#e88a87',
        '#fcdad9',
        ]}
    series=repo
/>

# Model Growth Monthly

```sql model_creations_by_month
SELECT month, repo, creations
FROM ${hub_growth}
WHERE repo = 'model'
```

<AreaChart 
    data={model_creations_by_month}
    x=month
    fillColor="#cf0d06"
    strokeColor="#eb5752"
    labels=true
    y=creations
/>

# Dataset Growth Monthly

```sql dataset_creations_by_month
SELECT month, repo, creations
FROM ${hub_growth}
WHERE repo = 'dataset'
```

<AreaChart 
    data={dataset_creations_by_month}
    x=month
    fillColor="#cf0d06"
    strokeColor="#eb5752"
    labels=true
    y=creations
/>

# Space Growth Monthly

```sql space_creations_by_month
SELECT month, repo, creations
FROM ${hub_growth}
WHERE repo = 'space'
```

<AreaChart 
    data={space_creations_by_month}
    x=month
    y=creations
    fillColor="#cf0d06"
    strokeColor="#eb5752"
    labels=true
/>

# Model Downloads by Pipeline Tag (Last 30 days)

```sql model_pipeline_downloads
SELECT
  pipeline_tag, SUM(downloads) as total_downloads
FROM read_parquet('https://huggingface.co/datasets/cfahlgren1/hub-stats/resolve/refs%2Fconvert%2Fparquet/models/train/0000.parquet?download=true')
  GROUP BY pipeline_tag
  ORDER BY total_downloads DESC;
```

<BarChart
  data={model_pipeline_downloads}
  x=pipeline_tag
  y=total_downloads
  yAxisTitle="Downloads Last 30 Days"
  xAxisTitle="Pipeline Tag"
  sort=true
  fillColor="#cf0d06"
  strokeColor="#eb5752"
/>
<DataTable data={model_pipeline_downloads} search=true>
  <Column id="pipeline_tag" title="Pipeline Tag" />
  <Column id="total_downloads" title="Downloads Last 30 Days" fmt='#,##0.00,,"M"' />
</DataTable>

# Model Licenses

```sql model_license_ratio
  SELECT SUBSTRING(name, 9) AS name, COUNT(*) as value
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

# Dataset Licenses

```sql dataset_license_ratio
  SELECT SUBSTRING(name, 9) AS name, COUNT(*) as value
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

# Hub Stats Dataset
<iframe
  src="https://huggingface.co/datasets/cfahlgren1/hub-stats/embed/viewer/datasets/train"
  frameborder="0"
  width="100%"
  height="560px"
></iframe>