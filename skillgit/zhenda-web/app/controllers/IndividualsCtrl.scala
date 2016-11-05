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
import models.business.individuals._
import models.misc._
import play.api.i18n._
import play.api.mvc._
import security._
import views._

/**
 * @author zepeng.li@factchina.com
 */
class IndividualsCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _individuals: Individuals
) extends IndividualCanonicalNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[IndividualsCtrl.AccessDef]
  with IndividualsCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with I18nSupport {

  def index(p: Pager, sort: Seq[SortField]) = {
    val default = _individuals.sorting(_.resident_id_record_ids.asc)
    UserAction(_.P03, _.P00, _.P02, _.P04).apply { implicit req =>
      Ok(html.individuals.index(p, if (sort.nonEmpty) sort else default))
    }
  }

  def nnew =
    UserAction(_.P00).apply { implicit req =>
      Ok(html.individuals.nnew())
    }

  def edit(id: UUID) =
    UserAction(_.P04).apply { implicit req =>
      Ok(html.individuals.edit(id))
    }
}

object IndividualsCtrl
  extends IndividualCanonicalNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    def values = Seq(P00, P02, P03, P04)
  }

  object AccessDef extends AccessDef

}