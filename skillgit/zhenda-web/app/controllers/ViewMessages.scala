/*
 * Copyright (c) Factchina Inc, 2015-2016
 *
 * This unpublished material is proprietary to Factchina Inc.
 * All rights reserved. The methods and techniques described herein
 * are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part,
 * is forbidden except by express written permission of Factchina Inc.
 */
package controllers

import helpers.CanonicalNamed
import play.api.i18n._

/**
 * @author zepeng.li@factchina.com
 */
trait ViewMessages {
  self: CanonicalNamed =>

  def msg(key: String, args: Any*)(implicit messages: Messages) = {
    messages(s"views.$basicName.$key", args: _*)
  }
}