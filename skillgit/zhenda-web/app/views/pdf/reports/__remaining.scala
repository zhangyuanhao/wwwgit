/*
 * Copyright (c) Factchina Inc, 2015-2016
 *
 * This unpublished material is proprietary to Factchina Inc.
 * All rights reserved. The methods and techniques described herein
 * are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part,
 * is forbidden except by express written permission of Factchina Inc.
 */
package views.fo.pdf.reports

import helpers.EnumLike._
import models.business.services._
import play.api.i18n.Messages
import play.twirl.api.Xml
import views.ClassFormats._

/**
 * 背景调查服务，暂时无法核实的原因
 */
object __remaining {

  def apply(remaining: Remaining[_ <: Value], definition: Definition[_ <: Value])(
    implicit messages: Messages
  ): Xml = {
    val comment = remaining.reasons.map {
      reason => definition.msg(reason)
    } + remaining.other.format + remaining.comment.format

    Xml(comment.mkString("\n"))
  }
}