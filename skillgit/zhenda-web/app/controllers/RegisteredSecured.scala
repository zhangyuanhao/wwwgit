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

import play.api.i18n.Messages
import play.api.libs.json._
import security._

/**
 * @author zepeng.li@factchina.com
 */
class RegisteredSecured(
  val modules: PermissionCheckable*
) {

  object Modules {

    def names: Seq[String] = modules.map(_.checkedModuleName.name)

    def toJson(implicit messages: Messages) = Json.prettyPrint(
      JsObject(
        names.map { name =>
          name -> JsString(messages(s"$name.name"))
        }
      )
    )
  }

  object AccessDef {

    def toJson(implicit messages: Messages) = Json.prettyPrint(
      Json.toJson(
        modules.map { m =>
          val name = m.checkedModuleName.name
          name ->
            m.AccessDef.values.map { p =>
              p.self.toString -> messages(s"$name.ac.$p")
            }.toMap
        }.toMap
      )
    )
  }
}