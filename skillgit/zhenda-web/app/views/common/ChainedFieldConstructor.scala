/*
 * Copyright (c) Factchina Inc, 2015-2016
 *
 * This unpublished material is proprietary to Factchina Inc.
 * All rights reserved. The methods and techniques described herein
 * are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part,
 * is forbidden except by express written permission of Factchina Inc.
 */
package views.html

import play.twirl.api.Html
import views.html.helper.{FieldConstructor, FieldElements}

/**
 * @author zepeng.li@factchina.com
 */
case class ChainedFieldConstructor(fc: FieldConstructor, others: FieldConstructor*) extends FieldConstructor {

  def apply(elts: FieldElements): Html = {
    (fc(elts) /: others)((html, fc) => fc(elts.copy(input = html)))
  }
}