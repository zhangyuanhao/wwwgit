/*
 * Copyright (c) Factchina Inc, 2015-2016
 *
 * This unpublished material is proprietary to Factchina Inc.
 * All rights reserved. The methods and techniques described herein
 * are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part,
 * is forbidden except by express written permission of Factchina Inc.
 */

package views.fo.pdf.authorization_letters

import models.business.infogathering._
import play.api.i18n._

/**
 * PDF授权书的元信息
 */
object metadata {

  /**
   * PDF授权书的文件名规则
   */
  def filename(report: Authorization.Handwritten): String = {
    // 文件名过长会导致Safari无法处理，从而导致下载的文件名乱码
    s"""FACT授权书.pdf"""
  }

  /**
   * PDF授权书的Title
   */
  def title(report: Authorization.Handwritten): String = {
    s"""FACT授权书"""
  }

  /**
   * PDF授权书的Subject
   */
  def subject(report: Authorization.Handwritten): String = {
    s"""FACT授权书"""
  }

  /**
   * PDF授权书的关键字
   */
  def keywords(report: Authorization.Handwritten): Seq[String] = Nil
}