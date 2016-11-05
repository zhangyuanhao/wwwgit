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
import elasticsearch.mappings._
import helpers._
import models.business.customers._
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
class CustomerUserOrdersCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _ourCompany: OurCompany,
  val _orders: Orders
) extends CustomerUserOrdersCNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[CustomerUserOrdersCtrl.AccessDef]
  with CustomerUserActionComponents[CustomerUserOrdersCtrl.AccessDef]
  with CustomerUserOrdersCtrl.AccessDef
  with ExceptionHandlers
  with IndexedOrdersComponents
  with CustomerRegionComponents
  with MediatorRegionComponents
  with CustomerUserRegionComponents
  with AkkaTimeOutConfig
  with DefaultPlayExecutor
  with I18nSupport {

  def index(pager: Pager, sort: Seq[SortField]) = {
    CustomerUserAction(_.P03, _.P00, _.P02).apply { implicit req =>
      val default = _indexedOrdersOfCustomer(req.customer).sorting(_.created_at.desc)
      Ok(html.orders.index(req.customer.cid, pager, if (sort.nonEmpty) sort else default))
    }
  }

  def parts(sub: String) =
    CustomerUserAction(_.P03).apply { implicit req =>
      sub match {
        case "all_orders"          => Ok(html.orders.parts._all_orders())
        case "search_orders"       => Ok(html.orders.parts._search_orders())
        case "awaiting_submission" => Ok(html.orders.parts._awaiting_submission())
        case "in_progress"         => Ok(html.orders.parts._in_progress())
        case "basically_completed" => Ok(html.orders.parts._basically_completed())
        case "finally_completed"   => Ok(html.orders.parts._finally_completed())
        case "customer_complained" => Ok(html.orders.parts._customer_complained())
      }
    }

  def nnew =
    CustomerUserAction(_.P00).async { implicit req =>
      for {
        pid <- _ourCompany.id
        contract <- (_mediator(req.customer.mediator(pid)) ? (_.Contracts.GetLast())).mapTo[Contract]
      } yield {
        Ok(html.orders.nnew(req.customer.cid, contract.content.purchasedServices))
      }
    }

  def show(id: UUID) =
    CustomerUserAction(_.P02, _.P04).async { implicit req =>
      _orders.find(id).map { o =>
        Ok(html.orders.show(req.customer.cid, id, o.purchased_services))
      }
    }

  def edit(id: UUID) =
    CustomerUserAction(_.P04).async { implicit req =>
      _orders.find(id).map { o =>
        Ok(html.orders.edit(req.customer.cid, id, o.purchased_services))
      }
    }

  def metrics() =
    CustomerUserAction(_.P16).apply { implicit req =>
      Ok(html.orders.metrics(req.customer.cid))
    }
}

object CustomerUserOrdersCtrl
  extends CustomerUserOrdersCNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** Access : Order Metrics View */
    val P16 = Access.Pos(16)

    def values = Seq(P00, P02, P03, P04, P16)
  }

  object AccessDef extends AccessDef

  object StatusDef {

    /**
     * 用来判断可否进行修改订单操作的状态序列
     *
     * 返回Json如:
     * {{{
     * {
     * 'New' : 0
     * 'AwaitingSubmission' : 1
     * }
     * }}}
     *
     * @return 一个包含 status -> status index 序列的JsObject
     */
    def toSeqArray = Json.prettyPrint(
      JsObject(
        Order.Status.values.zipWithIndex.map { case (k, v) => k.self -> JsNumber(v) }
      )
    )
  }
}