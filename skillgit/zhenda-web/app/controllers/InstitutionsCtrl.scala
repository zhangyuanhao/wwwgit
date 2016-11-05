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
import models.fact._
import models.misc._
import play.api.i18n._
import play.api.mvc._
import security._
import views._

/**
 * @author zepeng.li@factchina.com
 */
class InstitutionsCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _institutions: Institutions
) extends InstitutionCanonicalNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[InstitutionsCtrl.AccessDef]
  with InstitutionsCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with I18nSupport {

  def index(pager: Pager, sort: Seq[SortField]) = {
    val default = _institutions.sorting(
      _.name.asc,
      _.former_name.asc
    )
    UserAction(_.P03, _.P00, _.P04).apply { implicit req =>
      Ok(html.institutions.index(pager, if (sort.nonEmpty) sort else default))
    }
  }

  def nnew =
    UserAction(_.P00).apply { implicit req =>
      Ok(html.institutions.edit(None))
    }

  def edit(id: UUID) =
    UserAction(_.P04).apply { implicit req =>
      Ok(html.institutions.edit(Some(id)))
    }

}

object InstitutionsCtrl
  extends InstitutionCanonicalNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    def values = Seq(P00, P03, P04)
  }

  object AccessDef extends AccessDef

}