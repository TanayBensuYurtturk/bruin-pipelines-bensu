/* @bruin
name: wikipedia_attention.article_trends
type: bq.sql
description: Dashboard table with article rankings and previous-day changes. Missing comparisons stay null; views cover only the captured top list.
depends:
  - wikipedia_attention.top_articles
materialization:
  type: table
  partition_by: view_date
  cluster_by:
    - project
@bruin */

WITH ranked AS (
    SELECT
        view_date,
        project,
        article,
        REPLACE(article, '_', ' ') AS article_title,
        CONCAT('https://', project, '/wiki/', article) AS article_url,
        ROW_NUMBER() OVER (
            PARTITION BY view_date, project ORDER BY views DESC, source_rank, article
        ) AS article_rank,
        views,
        fetched_at
    FROM wikipedia_attention.top_articles
    WHERE article NOT IN ('Main_Page', 'Anasayfa', 'Ana_Sayfa')
      AND NOT REGEXP_CONTAINS(article, r'^(Special|Wikipedia|Help|Portal|File|Category|Template|Talk|User|MediaWiki|Özel|Vikipedi|Yardım|Dosya|Kategori|Şablon|Tartışma|Kullanıcı|Modül|Module):')
)

SELECT
    current_day.*,
    previous_day.views AS previous_day_views,
    previous_day.article_rank - current_day.article_rank AS rank_change,
    ROUND(100.0 * SAFE_DIVIDE(
        current_day.views - previous_day.views, previous_day.views
    ), 2) AS views_change_pct,
    current_day.view_date = MAX(current_day.view_date) OVER (
        PARTITION BY current_day.project
    ) AS is_latest_day
FROM ranked AS current_day
LEFT JOIN ranked AS previous_day
    ON current_day.project = previous_day.project
    AND current_day.article = previous_day.article
    AND previous_day.view_date = DATE_SUB(current_day.view_date, INTERVAL 1 DAY)
