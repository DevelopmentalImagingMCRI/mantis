---
layout: default
title: Setting image origin
---

<section role="banner">
  <img src="{{ site.baseurl }}{{ post.url }}/img/banner.jpg" />
</section>

# Image origin

In SPM the image origin needs to be approximately equivalent to the
origin of the template. If it is too far off the registration steps
can't cope.

MANTiS includes a simple tool to set the origin based on centre of mass. This
tool is derived from an equivalent function in the VBM8 package and should
be applied to brain extracted images. It is available via the batch
interface and can be combined with the brain extraction tool.

This is an optional step if tissue classification doesn't appear to make
sense.
