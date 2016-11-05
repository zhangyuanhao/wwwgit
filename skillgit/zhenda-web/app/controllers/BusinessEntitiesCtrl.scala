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
 * @author shu.zhang@factchina.com
 */
class BusinessEntitiesCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _bes: BusinessEntities
) extends BusinessEntityCanonicalNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[BusinessEntitiesCtrl.AccessDef]
  with BusinessEntitiesCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with I18nSupport {

  def index(pager: Pager, sort: Seq[SortField]) = {
    val default = _bes.sorting(_.name.asc)
    UserAction(_.P03, _.P00, _.P04).apply { implicit req =>
      Ok(html.business_entities.index(pager, if (sort.nonEmpty) sort else default))
    }
  }

  def nnew() =
    UserAction(_.P00).apply { implicit req =>
      Ok(html.business_entities.nnew())
    }

  def edit(id: UUID) =
    UserAction(_.P04).apply { implicit req =>
      Ok(html.business_entities.edit(id))
    }
}

object BusinessEntitiesCtrl
  extends BusinessEntityCanonicalNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    def values = Seq(P00, P03, P04)
  }

  object AccessDef extends AccessDef

}