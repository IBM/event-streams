---
title: "UI shows black images in Firefox"
excerpt: "When using Firefox browser the Event Streams UI shows black images."
categories: troubleshooting
slug: firefox-black-images
layout: redirects
toc: true
---

## Symptoms

Images in the {{site.data.reuse.short_name}} UI are rendered as a black-filled shape instead of the correct image as shown in the following example:

!['Event Streams UI with black rendered images']({{ 'images' | relative_url }}/ff-black-images.png "Image showing a screenshot of the Event Streams UI with black rendered images")

## Causes

Mozilla Firefox 76 and earlier versions block the inline CSS styling in SVG images. This is because they incorrectly apply the page-level Content Security Policy against the SVG images.

## Resolving the problem

Update your Firefox version to 77 or later as the issue has been resolved in Firefox 77.
