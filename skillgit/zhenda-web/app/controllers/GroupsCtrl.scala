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
import models._
import models.misc._
import play.api.i18n._
import play.api.libs.json._
import play.api.mvc.Controller
import security._
import views._

/**
 * @author zepeng.li@factchina.com
 */
class GroupsCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired
) extends GroupCanonicalNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[GroupsCtrl.AccessDef]
  with GroupsCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with I18nSupport {

  def index(pager: Pager, sort: Seq[SortField]) =
    UserAction(_.P03, _.P01, _.P02, _.P05, _.P06).apply { implicit req =>
      val default = _groups.sorting(_.group_name.asc)
      Ok(html.groups.index(pager, if (sort.nonEmpty) sort else default))
    }

  def show(id: UUID) =
    UserAction(_.P02, _.P16, _.P17).async { implicit req =>
      _groups.find(id).map { grp =>
        if (grp.is_internal) Redirect(routes.GroupsCtrl.index())
        else Ok(html.groups.show(grp))
      }
    }
}

object GroupsCtrl
  extends GroupCanonicalNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** Add User */
    val P16 = Access.Pos(16)

    /** Remove User */
    val P17 = Access.Pos(17)

    def values = Seq(P01, P02, P03, P05, P06, P16, P17)
  }

  object AccessDef extends AccessDef

  def groupNames(groups: Seq[Group]) = Json.prettyPrint(
    JsObject(
      groups.map(g => g.id.toString -> JsString(g.group_name.self))
    )
  )

  def intGroupNames(groups: Seq[Group]) = Json.prettyPrint(
    JsObject(
      groups.zipWithIndex.map(p => p._2.toString -> JsString(p._1.group_name.self))
    )
  )
}