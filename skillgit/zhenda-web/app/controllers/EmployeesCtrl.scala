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

import elasticsearch._
import helpers._
import models.business.providers._
import models.misc._
import play.api.i18n._
import play.api.libs.json._
import play.api.mvc._
import security._
import services.actors._
import views._

/**
 * @author zepeng.li@factchina.com
 */
class EmployeesCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _ourCompany: OurCompany,
  val _employees: Employees
) extends EmployeeCanonicalNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[EmployeesCtrl.AccessDef]
  with EmployeesCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with I18nSupport {

  def index(p: Pager, sort: Seq[SortField]) = {
    val default = _employees.sorting(_.nickname.asc)
    UserAction(_.P03, _.P00, _.P04).apply { implicit req =>
      Ok(html.employees.index(p, if (sort.nonEmpty) sort else default))
    }
  }

  def nnew =
    UserAction(_.P00).apply { implicit req =>
      Ok(html.employees.nnew())
    }

  def edit(id: UUID) =
    UserAction(_.P04).async { implicit req =>
      for {
        pid <- _ourCompany.provider_id
        emp <- _employees.find(pid.employee(id))
      } yield {
        Ok(html.employees.edit(emp))
      }
    }

  def performance =
    UserAction(_.P16).apply { implicit req =>
      Ok(html.employees.performance())
    }
}

object EmployeesCtrl
  extends EmployeeCanonicalNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** Access : Index employees performance */
    val P16 = Access.Pos(16)

    def values = Seq(P00, P03, P04, P16)
  }

  object AccessDef extends AccessDef

  object LevelOfRoleDef {

    /**
     * 取得所有Level的value的定义
     */
    def toJson = Json.prettyPrint(
      JsArray(
        Employee.LevelOfRole.values.map { level => JsString(level.toString) }
      )
    )

    /**
     * 取得画面显示用的所有角色对应level的message
     */
    def toAllRolesJson(implicit messages: Messages) = {
      Json.prettyPrint(
        JsArray(
          Employee.Role.values.map { pos =>
            JsArray(
              Employee.LevelOfRole.values.map { v =>
                JsString(Employee.LevelOfRole.msg(v, pos.toString))
              }
            )
          }
        )
      )
    }
  }

}