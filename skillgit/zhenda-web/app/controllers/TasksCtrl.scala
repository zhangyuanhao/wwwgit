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

import java.util.UUID

import helpers._
import models.business.providers._
import play.api.i18n._
import play.api.mvc._
import security._
import views.html

/**
 * @author shu.zhang@factchina.com
 */
class TasksCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _tasks: Tasks
) extends TaskCanonicalNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[TasksCtrl.AccessDef]
  with TasksCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with I18nSupport {

  def task(id: UUID, task_type: Task.Type) =
    UserAction(_.P02).async { implicit req =>
      _tasks.find(id).map { task =>
        task_type match {
          case Task.Type.Qualification =>
            Ok(html.tasks.qualification_task(id, task.order_id))
          case Task.Type.Employment    =>
            Ok(html.tasks.employment_task(id, task.order_id))
          case _                       =>
            NotFound
        }
      }
    }

  def review(id: UUID, task_type: Task.Type) =
    UserAction(_.P16).async { implicit req =>
      _tasks.find(id).map { task =>
        task_type match {
          case Task.Type.Qualification =>
            Ok(html.tasks.qualification_review(id, task.order_id))
          case Task.Type.Employment    =>
            Ok(html.tasks.employment_review(id, task.order_id))
          case _                       =>
            NotFound
        }
      }
    }

}

object TasksCtrl
  extends TaskCanonicalNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** Access : Review */
    val P16 = Access.Pos(16)

    def values = Seq(P02, P16)
  }

  object AccessDef extends AccessDef

}