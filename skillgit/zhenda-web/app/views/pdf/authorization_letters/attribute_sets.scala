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

import views.fo.Magic._

/**
 * PDF中的样式定义
 *
 * @author zepeng.li@factchina.com
 */
object attribute_sets {

  /**
   * 返回预定义的属性集合
   *
   * @param keys 一个或多个属性集合的名字
   * @return 如有相同属性则后者会覆盖前者
   */
  def apply(keys: String*) = toXmlArgs(keys.flatMap(definitions.get).flatten.toMap)

  val definitions = Map(

    "page-one" -> Seq(
      "page-height" -> "29.7cm",
      "page-width" -> "21cm",
      "margin-top" -> "1cm",
      "margin-bottom" -> "1cm",
      "margin-left" -> "3cm",
      "margin-right" -> "3cm"
    ),

    "region-body" -> Seq(
      "space-before" -> "2.0cm",
      "space-after" -> "1.2cm"
    ),

    "header" -> Seq(
      "extent" -> "1.9cm"
    ),

    "footer" -> Seq(
      "extent" -> "1.1cm"
    ),

    "traffic-lights" -> Seq(
      "content-height" -> "12pt",
      "padding-top" -> "-1px",
      "padding-bottom" -> "-2px"
    ),

    "header-row-en" -> Seq(
      "font-size" -> "11pt",
      "line-height" -> "15pt",
      "font-family" -> "Microsoft YaHei Bold",
      "text-align" -> "center",
      "padding-top" -> "5pt",
      "padding-bottom" -> "5pt"
    ),

    "header-row-zh" -> Seq(
      "font-size" -> "11pt",
      "line-height" -> "15pt",
      "text-align" -> "center",
      "padding-top" -> "5pt",
      "padding-bottom" -> "5pt"
    ),

    "block-first-row-en" -> Seq(
      "font-size" -> "9pt",
      "font-family" -> "Microsoft YaHei Bold",
      "padding-top" -> "8pt",
      "padding-bottom" -> "8pt"
    ),

    "block-first-row-zh" -> Seq(
      "font-size" -> "9pt",
      "padding-top" -> "8pt",
      "padding-bottom" -> "8pt"
    ),

    "block-rest-row-en" -> Seq(
      "font-size" -> "8pt",
      "line-height" -> "15pt",
      "text-align" -> "justify",
      "padding-top" -> "8pt",
      "padding-bottom" -> "8pt"
    ),

    "block-rest-row-zh" -> Seq(
      "font-size" -> "9pt",
      "line-height" -> "18pt",
      "text-align" -> "justify",
      "padding-top" -> "8pt",
      "padding-bottom" -> "8pt"
    ),

    "input-row-en" -> Seq(
      "font-size" -> "9pt",
      "font-family" -> "Microsoft YaHei Bold",
      "padding-top" -> "8pt",
      "padding-bottom" -> "8pt"
    ),

    "input-row-zh-1" -> Seq(
      "font-size" -> "9pt",
      "padding-top" -> "8pt",
      "padding-bottom" -> "20pt"
    ),

    "input-row-zh-2" -> Seq(
      "font-size" -> "9pt",
      "padding-top" -> "8pt",
      "padding-bottom" -> "0pt"
    ),

    "footer-row-en" -> Seq(
      "font-size" -> "9pt",
      "line-height" -> "15pt",
      "text-align" -> "center",
      "padding-top" -> "5pt",
      "padding-bottom" -> "5pt"
    ),

    "footer-row-zh" -> Seq(
      "font-size" -> "9pt",
      "line-height" -> "15pt",
      "text-align" -> "center",
      "padding-top" -> "5pt",
      "padding-bottom" -> "5pt"
    ),

    "line" -> Seq(
      "border-top" -> "1px solid"
    ),

    "signature" -> Seq(
      "content-height" -> "24pt",
      "padding-top" -> "-8pt",
      "padding-bottom" -> "10pt"
    ),

    "spacer-lg" -> Seq(
      "margin-top" -> "1cm"
    )
  )
}