#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

$(document).ready(
  fix_height = ->
    navbarHeight = $('nav.navbar-default').height()
    wrapperHeight = $('.page-wrapper').height()
    windowHeight = $(window).height()

    if navbarHeight > wrapperHeight
      $('.page-wrapper').css("min-height", Math.max(navbarHeight, windowHeight) + "px")

    if navbarHeight < wrapperHeight
      $('.page-wrapper').css("min-height", windowHeight + "px")

  $(window).bind("load resize scroll", ->
    if !$("body").hasClass('body-small') then fix_height())

  fix_height()
)