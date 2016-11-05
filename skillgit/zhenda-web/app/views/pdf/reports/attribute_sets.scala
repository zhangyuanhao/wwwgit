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

    "zh-page-first" -> Seq(
      "page-height" -> "29.7cm",
      "page-width" -> "21cm",
      "margin-top" -> "3cm",
      "margin-bottom" -> "2.5cm",
      "margin-left" -> "4cm",
      "margin-right" -> "4cm"
    ),

    "page-rest" -> Seq(
      "page-height" -> "29.7cm",
      "page-width" -> "21cm",
      "margin-top" -> "3cm",
      "margin-bottom" -> "1.8cm",
      "margin-left" -> "3cm",
      "margin-right" -> "3cm"
    ),

    "en-page-first" -> Seq(
      "page-height" -> "29.7cm",
      "page-width" -> "21cm",
      "margin-top" -> "3cm",
      "margin-bottom" -> "2.5cm",
      "margin-left" -> "3cm",
      "margin-right" -> "3cm"
    ),

    "logo" -> Seq(
      "margin-top" -> "100pt",
      "margin-bottom" -> "40pt"
    ),

    "logo-image" -> Seq(
      "content-height" -> "64pt"
    ),

    "report-title" -> Seq(
      "font-family" -> "Microsoft YaHei Bold",
      "font-size" -> "24pt",
      "line-height" -> "40pt",
      "space-after.optimum" -> "20pt",
      "text-align" -> "justify",
      "text-align-last" -> "center",
      "padding-top" -> "3pt"
    ),

    "region-body" -> Seq(
      "space-after" -> "1.2cm"
    ),

    "footer" -> Seq(
      "extent" -> "1.1cm"
    ),

    "footer-text" -> Seq(
      "font-size" -> "9pt",
      "line-height" -> "11pt"
    ),

    "zh-disclaimer" -> Seq(
      "line-height" -> "24pt",
      "font-size" -> "9pt"
    ),

    "zh-disclaimer-head" -> Seq(
      "text-align" -> "center"
    ),

    "zh-disclaimer-body" -> Seq(
      "text-align" -> "justify"
    ),

    "en-disclaimer" -> Seq(
      "line-height" -> "20pt",
      "font-size" -> "8pt"
    ),

    "en-disclaimer-head" -> Seq(
      "text-align" -> "center",
      "font-family" -> "Microsoft YaHei Bold"
    ),

    "en-disclaimer-body" -> Seq(
      "text-align" -> "justify"
    ),

    "page-breaker" -> Seq(
      "page-break-before" -> "always"
    ),

    "section-header" -> Seq(
      "font-family" -> "Microsoft YaHei Bold",
      "font-selection-strategy" -> "character-by-character",
      "font-size" -> "14pt",
      "line-height" -> "24pt",
      "space-after.optimum" -> "20pt",
      "color" -> "#670908",
      "text-align" -> "center",
      "padding-top" -> "3pt"
    ),

    "panel" -> Seq(
      "table-layout" -> "fixed",
      "width" -> "100%",
      "border" -> "solid 0.3pt",
      "border-collapse" -> "separate",
      "border-spacing" -> "-0.1pt"
    ),

    "zh-panel" -> Seq(
      "font-size" -> "10pt"
    ),

    "en-panel" -> Seq(
      "font-size" -> "9pt"
    ),

    "panel-block" -> Seq(
      "keep-together.within-page" -> "always"
    ),

    "margin-bottom-sm" -> Seq(
      "margin-bottom" -> "28pt"
    ),

    "margin-bottom-md" -> Seq(
      "margin-bottom" -> "50pt"
    ),

    "panel-header" -> Seq(
      "background-color" -> "#640000",
      "color" -> "#FFFFFF",
      "font-size" -> "10pt",
      "font-family" -> "Microsoft YaHei Bold",
      "text-align" -> "center",
      "padding" -> "3pt 5pt 1pt"
    ),

    "panel-cell" -> Seq(
      "border" -> "solid 0.3pt",
      "display-align" -> "center",
      "padding" -> "3pt 5pt 1pt"
    ),

    "traffic-lights" -> Seq(
      "content-height" -> "12pt",
      "padding-top" -> "-1px",
      "padding-bottom" -> "-2px"
    ),

    "bg-default" -> Seq(
      "background-color" -> "#D9D9D9"
    ),

    "fa" -> Seq(
      "font-family" -> "FontAwesome"
    ),

    "icon-success" -> Seq(
      "color" -> "#5cb85c"
    ),

    "icon-info" -> Seq(
      "color" -> "#5bc0de"
    ),

    "icon-warning" -> Seq(
      "color" -> "#f0ad4e"
    ),

    "icon-warning2" -> Seq(
      "color" -> "#f89515"
    ),

    "icon-danger" -> Seq(
      "color" -> "#d9534f"
    ),

    "icon-default" -> Seq(
      "color" -> "#5a5a5a"
    ),

    "text-success" -> Seq(
      "color" -> "#3c763d"
    ),

    "text-info" -> Seq(
      "color" -> "#31708f"
    ),

    "text-warning" -> Seq(
      "color" -> "#8a6d3b"
    ),

    "text-danger" -> Seq(
      "color" -> "#a94442"
    ),

    "pre-line" -> Seq(
      "wrap-option" -> "wrap",
      "linefeed-treatment" -> "preserve",
      "white-space-collapse" -> "false",
      "white-space-treatment" -> "preserve"
    ),

    "text-strong" -> Seq(
      "font-family" -> "Microsoft YaHei Bold"
    ),

    "text-center" -> Seq(
      "text-align" -> "center"
    ),

    "text-end" -> Seq(
      "text-align" -> "end"
    )
  )
}