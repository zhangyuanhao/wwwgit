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

import helpers._
import models._
import models.misc._
import play.api.i18n.Messages
import play.api.libs.json.Json
import views.html

import scala.concurrent._
import scala.util.Success

/**
 * @author zepeng.li@factchina.com
 */
object Layouts extends Logging {

  import html.layouts._

  val layout_admin    = Layout(base_admin.getClass.getCanonicalName)
  val layout_employee = Layout(base_employee.getClass.getCanonicalName)
  val layout_customer = Layout(base_customer.getClass.getCanonicalName)
  val layout_normal   = Layout(base_normal.getClass.getCanonicalName)

  def toJson(implicit messages: Messages) =
    Json.prettyPrint(
      Json.obj(
        layout_admin.layout -> messages("layout.admin"),
        layout_employee.layout -> messages("layout.employee"),
        layout_customer.layout -> messages("layout.customer"),
        layout_normal.layout -> messages("layout.normal"),
        "" -> messages("layout.nothing")
      )
    )

  def initIfFirstRun(
    implicit
    _internalGroups: InternalGroups,
    ec: ExecutionContext
  ): Future[Boolean] = {
    _internalGroups
      .setLayout(_internalGroups.AnyoneId, layout_admin)
      .andThen { case Success(true) =>
        Logger.info("Initialized layout of Anyone.")
      }
  }
}