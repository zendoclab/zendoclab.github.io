# 게시물 작성 및 배포

이 저장소는 Jekyll과 GitHub Pages를 사용한다. 게시물은 `_posts` 디렉터리에
`YYYY-MM-DD-slug.md` 형식으로 저장하며, `main` 브랜치에 푸시하면
`.github/workflows/pages.yml`이 사이트를 빌드하고 배포한다.

사이트의 기준 시간대는 `_config.yml`의 `timezone: Asia/Seoul`이다. 각 게시물에도
한국시간 오프셋을 포함한 `date`를 명시한다. 이 값이 없으면 오전 9시 이전에
작성한 한국 날짜의 글이 GitHub Actions의 UTC 환경에서 미래 게시물로 판단될 수
있다.

## 가장 간단한 방법

1. front matter가 없는 본문 파일을 만든다. 예: `draft.md`
2. 저장소 루트에서 다음 명령을 실행한다.

```powershell
.\scripts\publish-post.ps1 `
  -Title "Article title" `
  -BodyPath .\draft.md `
  -Slug "article-slug" `
  -Excerpt "A short description shown on the post list." `
  -Categories ai,google `
  -Push
```

스크립트는 다음 작업을 수행한다.

1. 현재 시각을 `Asia/Seoul`로 변환한다.
2. 올바른 Jekyll front matter와 `_posts` 파일을 생성한다.
3. 생성한 게시물 파일만 Git에 추가하고 커밋한다.
4. 현재 브랜치를 `origin`에 푸시한다.
5. GitHub Pages 작업이 끝날 때까지 기다린다.
6. 배포된 게시물 URL이 HTTP 200을 반환하는지 확인한다.

`-Push`를 생략하면 파일만 생성하므로 내용을 검토한 뒤 나중에 배포할 수 있다.

```powershell
.\scripts\publish-post.ps1 `
  -Title "Article title" `
  -BodyPath .\draft.md `
  -Slug "article-slug" `
  -Categories notes
```

검토 후에는 생성된 파일 경로를 확인하고 일반적인 Git 명령으로 배포하거나,
파일을 삭제한 뒤 `-Push`를 포함해 명령을 다시 실행한다. 스크립트는 기존 파일을
덮어쓰지 않는다.

## 주요 옵션

| 옵션 | 설명 |
| --- | --- |
| `-Title` | 게시물 제목. 필수 |
| `-BodyPath` | front matter가 없는 Markdown 본문 파일. 필수 |
| `-Slug` | URL에 사용할 영문 소문자 슬러그. 생략하면 제목에서 자동 생성 |
| `-Excerpt` | 목록과 검색 메타데이터에 표시할 짧은 설명 |
| `-Categories` | 카테고리 배열. URL 경로에도 포함됨 |
| `-PublishAt` | 게시 시각. 생략하면 현재 한국시간 |
| `-Push` | 생성 후 커밋, 푸시, 배포 확인까지 수행 |
| `-Remote` | 푸시할 원격 저장소. 기본값 `origin` |
| `-Branch` | 푸시할 브랜치. 생략하면 현재 브랜치 |
| `-SkipDeploymentCheck` | 푸시 후 Actions와 실제 URL 확인을 생략 |

예약 게시가 필요하면 시간대가 포함된 값을 사용한다.

```powershell
-PublishAt "2026-07-30T09:00:00+09:00"
```

Jekyll은 미래 시각의 글을 빌드에서 제외하며 GitHub Pages는 게시 시각에 맞춰
자동으로 다시 빌드하지 않는다. 예약 시각 이후 Pages 워크플로를 수동 실행하거나
새 커밋을 푸시해야 한다.

## 생성되는 front matter

```yaml
---
layout: post
title: "Article title"
date: 2026-07-28 08:30:00 +0900
excerpt: "A short description shown on the post list."
categories: [ai, google]
---
```

기본 Jekyll permalink에는 카테고리가 포함된다. 위 예시의 URL은 다음 형태다.

```text
https://zendoclab.github.io/ai/google/2026/07/28/article-slug.html
```

## 수동 작성 절차

자동화 스크립트를 사용하지 않을 때도 다음 규칙을 지킨다.

1. `_posts/YYYY-MM-DD-slug.md`를 만든다.
2. `layout`, `title`, `date`, `categories`를 front matter에 작성한다.
3. `date`에는 `+0900`을 포함한다.
4. `git diff --check`로 형식 오류를 확인한다.
5. 해당 게시물만 커밋하고 `main`에 푸시한다.
6. GitHub Actions의 `Deploy Jekyll site to GitHub Pages`가 성공했는지 확인한다.
7. 홈페이지 링크와 실제 게시물 URL이 HTTP 200인지 확인한다.

```powershell
git diff --check
git add -- _posts/2026-07-28-article-slug.md
git commit -m "Publish article-slug"
git push origin main
```

## 문제 해결

### Actions는 성공했지만 글이 목록에 없음

게시물의 `date`가 빌드 시각보다 미래인지 확인한다. 한국 날짜만 파일명에 넣고
front matter의 `date`를 생략하면 UTC 환경에서 이런 문제가 발생할 수 있다.

### 예상한 URL이 404

홈페이지에서 실제 링크를 확인한다. 현재 설정에서는 `categories`가 URL 앞부분에
포함된다.

### 수정했는데 이전 내용이 보임

GitHub Pages CDN 캐시가 잠시 남아 있을 수 있다. Actions 배포 성공을 확인한 뒤
새로 고침하거나 URL 끝에 `?v=<commit-sha>`를 붙여 확인한다.

