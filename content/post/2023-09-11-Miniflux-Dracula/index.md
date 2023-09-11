---
title: "Dracula theme for Miniflux"
author: "Blagovest Petrov"
date: 2023-09-11T00:54:19+02:00
tags:
  - "CSS"
  - "RSS"
categories:
  - "Self Hosted"
draft: false
---

CSS theme for [Miniflux](https://miniflux.app/) with close colors to the [Dracula](https://draculatheme.com) theme.

```css
:root {
  --body-color: #f8f8f2;
  --body-background: #282a36;
  --hr-border-color: #44475a;
  --title-color: #50fa7b;
  --link-color: #f8f8f2;
  --link-focus-color: #8be9fd;
  --link-hover-color: #ff79c6;
  --link-visited-color: #6272a4;
  --header-list-border-color: #44475a;
  --header-link-color: #f8f8f2;
  --header-link-focus-color: #8be9fd;
  --header-link-hover-color: #ff79c6;
  --header-active-link-color: #ffb86c;
  --table-border-color: #44475a;
  --table-th-background: #282a36;
  --table-th-color: #f8f8f2;
  --table-tr-hover-background-color: #44475a;
  --table-tr-hover-color: #f8f8f2;
  --button-primary-border-color: #50fa7b;
  --button-primary-background: #50fa7b;
  --button-primary-color: #282a36;
  --button-primary-focus-border-color: #44475a;
  --button-primary-focus-background: #44475a;
  --input-background: #282a36;
  --input-color: #f8f8f2;
  --input-placeholder-color: #6272a4;
  --input-focus-color: #f8f8f2;
  --input-focus-border-color: #8be9fd;
  --input-focus-box-shadow: 0 0 0 2px #44475a;
  --alert-color: #f8f8f2;
  --alert-background-color: #282a36;
  --alert-border-color: #44475a;
  --alert-success-color: #f8f8f2;
  --alert-success-background-color: #50fa7b;
  --alert-success-border-color: #44475a;
  --alert-error-color: #f8f8f2;
  --alert-error-background-color: #ff5555;
  --alert-error-border-color: #44475a;
  --alert-info-color: #f8f8f2;
  --alert-info-background-color: #8be9fd;
  --alert-info-border-color: #44475a;
  --page-header-title-border-color: #44475a;
  --logo-color: #50fa7b;
  --logo-hover-color-span: #8be9fd;
  --panel-background: #282a36;
  --panel-border-color: #44475a;
  --panel-color: #f8f8f2;
  --modal-background: #282a36;
  --modal-color: #f8f8f2;
  --modal-box-shadow: 2px 0 5px 0 #44475a;
  --pagination-link-color: #f8f8f2;
  --pagination-border-color: #44475a;
  --category-color: #f8f8f2;
  --category-background-color: #44475a;
  --category-border-color: #44475a;
  --category-link-color: #f8f8f2;
  --category-link-hover-color: #50fa7b;
  --item-border-color: #44475a;
  --item-status-read-title-link-color: #50fa7b;
  --item-status-read-title-focus-color: #8be9fd;
  --item-meta-focus-color: #8be9fd;
  --item-meta-li-color: #f8f8f2;
  --current-item-border-color: #8be9fd;
  --entry-header-border-color: #44475a;
  --entry-header-title-link-color: #f8f8f2;
  --entry-content-color: #f8f8f2;
  --entry-content-code-color: #50fa7b;
  --entry-content-code-background: #282a36;
  --entry-content-code-border-color: #44475a;
  --entry-content-quote-color: #8be9fd;
  --entry-content-abbr-border-color: #44475a;
  --entry-enclosure-border-color: #44475a;
  --parsing-error-color: #f8f8f2;
  --feed-parsing-error-background-color: #ff5555;
  --feed-parsing-error-border-color: #44475a;
  --feed-has-unread-background-color: #50fa7b;
  --feed-has-unread-border-color: #44475a;
  --category-has-unread-background-color: #50fa7b;
  --category-has-unread-border-color: #44475a;
  --keyboard-shortcuts-li-color: #f8f8f2;
  --counter-color: #f8f8f2;
}

.entry-content {
  font-size: 1em;
}

.item {
  border: none;
}
```

Just paste it in the Settings.