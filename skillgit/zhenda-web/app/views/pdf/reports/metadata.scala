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

import models.business.customers._
import models.business.reports._
import models.business.services._
import play.api.i18n._
import views.ClassFormats._

/**
 * PDF背景调查报告的元信息
 */
object metadata {

  /**
   * PDF背景调查报告的文件名规则
   */
  def filename(report: BackgroundReport, status: Order.Status)(
    implicit messages: Messages
  ): String = {
    // 文件名过长会导致Safari无法处理，从而导致下载的文件名乱码
    s"""FACT雇前背景调查报告-${keywords0(report, status).mkString("-")}.pdf"""
  }

  /**
   * PDF背景调查报告的Title
   */
  def title(report: BackgroundReport, status: Order.Status)(
    implicit messages: Messages
  ): String = {
    s"""FACT雇前背景调查报告"""
  }

  /**
   * PDF背景调查报告的Subject
   */
  def subject(report: BackgroundReport, status: Order.Status)(
    implicit messages: Messages
  ): String = {
    s"""${keywords(report, status).mkString("-")}"""
  }

  /**
   * PDF背景调查报告的关键字
   */
  def keywords(report: BackgroundReport, status: Order.Status)(
    implicit messages: Messages
  ): Seq[String] = {
    report.customer_name.format +: keywords0(report, status)
  }

  /**
   * PDF背景调查报告的关键字(候选人姓名，报告状态，警示灯)
   */
  private def keywords0(report: BackgroundReport, status: Order.Status)(
    implicit messages: Messages
  ): Seq[String] = {
    val s1 = report.candidate_info.personal_name.format
    val s2 = Order.Status.msg(status, "1")
    val s3Opt = report.content.rating match {
      case Some(Level.Unknown) => None
      case Some(level)         => Some(Level.msg(level, "1"))
      case None                => None
    }
    Seq(s1, s2) ++ s3Opt
  }
}