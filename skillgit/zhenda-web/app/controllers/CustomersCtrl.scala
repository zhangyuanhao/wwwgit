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
import models.business.customers._
import models.misc._
import play.api.i18n._
import play.api.mvc._
import security._
import services.actors._
import views._

import scala.concurrent.Future

/**
 * @author zepeng.li@factchina.com
 */
class CustomersCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _ourCompany: OurCompany,
  val _customers: Customers
) extends CustomerCanonicalNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[CustomersCtrl.AccessDef]
  with CustomersCtrl.AccessDef
  with ExceptionHandlers
  with MediatorRegionComponents
  with CustomerRegionComponents
  with AkkaTimeOutConfig
  with DefaultPlayExecutor
  with I18nSupport {

  def index(p: Pager, sort: Seq[SortField]) = {
    val default = _customers.sorting(_.name.asc)
    UserAction(_.P03, _.P00, _.P04).apply { implicit req =>
      Ok(html.customers.index(p, if (sort.nonEmpty) sort else default))
    }
  }

  def our_customers(p: Pager) =
    UserAction(_.P16).apply { implicit req =>
      Ok(html.customers.our_customers(p))
    }

  def nnew() =
    UserAction(_.P00).apply { implicit req =>
      Ok(html.customers.nnew())
    }

  def edit(id: UUID) =
    UserAction(_.P04).async { implicit req =>
      _customers.find(Customer.ID(id)).map { customer =>
        Ok(html.customers.edit(customer))
      }.recover {
        case e: BaseException => NotFound
      }
    }

  def hrs(id: UUID) =
    UserAction(_.P17).async { implicit req =>
      _customers.find(Customer.ID(id)).map { customer =>
        Ok(html.customers.hrs(customer))
      }.recover {
        case e: BaseException => NotFound
      }
    }

  def orders(id: UUID) =
    UserAction(_.P18).async { implicit req =>
      _customers.find(Customer.ID(id)).map { customer =>
        Ok(html.customers.orders(customer))
      }.recover {
        case e: BaseException => NotFound
      }
    }

  def contract(id: UUID) =
    UserAction(_.P19).async { implicit req =>
      _customers.find(Customer.ID(id)).map { customer =>
        Ok(html.customers.contract(customer, "basic"))
      }.recover {
        case e: BaseException => NotFound
      }
    }

  def contractParts(sub_path: String) =
    UserAction(_.P19).apply { implicit req =>
      sub_path match {
        // side bar
        case "basic_side_bar"         => Ok(html.customers.contract_parts._basic_side_bar())
        case "qualification_side_bar" => Ok(html.customers.contract_parts._qualification_side_bar())
        case "education_side_bar"     => Ok(html.customers.contract_parts._education_side_bar())
        case "employment_side_bar"    => Ok(html.customers.contract_parts._employment_side_bar())
        // 基本设定
        case "basic_setting"      => Ok(html.customers.contract_parts._basic_setting())
        case "purchased_services" => Ok(html.customers.contract_parts._purchased_services())
        // 资质组
        case "identity"                      => Ok(html.customers.contract_parts._identity())
        case "professional_license"          => Ok(html.customers.contract_parts._professional_license())
        case "criminal_record"               => Ok(html.customers.contract_parts._criminal_record())
        case "illegal_organization_record"   => Ok(html.customers.contract_parts._illegal_organization_record())
        case "court_record"                  => Ok(html.customers.contract_parts._court_record())
        case "financial_irregularity"        => Ok(html.customers.contract_parts._financial_irregularity())
        case "conflict_of_business_interest" => Ok(html.customers.contract_parts._conflict_of_business_interest())
        // 学历
        case "highest_education" => Ok(html.customers.contract_parts._education(0))
        case "other_education"   => Ok(html.customers.contract_parts._education(1))
        // 工作履历
        case "last_personnel_officer"     => Ok(html.customers.contract_parts._employment(0, "PersonnelOfficer"))
        case "last_supervisor"            => Ok(html.customers.contract_parts._employment(0, "Supervisor"))
        case "last_additional1"           => Ok(html.customers.contract_parts._employment(0, "Additional1"))
        case "last_additional2"           => Ok(html.customers.contract_parts._employment(0, "Additional2"))
        case "previous_personnel_officer" => Ok(html.customers.contract_parts._employment(1, "PersonnelOfficer"))
        case "previous_supervisor"        => Ok(html.customers.contract_parts._employment(1, "Supervisor"))
        case "previous_additional1"       => Ok(html.customers.contract_parts._employment(1, "Additional1"))
        case "previous_additional2"       => Ok(html.customers.contract_parts._employment(1, "Additional2"))
      }
    }

  def preferences(id: UUID) =
    UserAction(_.P20).async { implicit req =>
      for {
        provider <- _ourCompany.id
        customer <- _customers.find(Customer.ID(id))
        contract <- {_mediator(customer.id.mediator(provider)) ? (_.Contracts.GetLast())}.mapTo[Contract]
      } yield {
        Ok(html.customers.preferences(customer, contract.content.purchasedServices))
      }
    }

  def invoice(customer_id: UUID, pager: Pager) = {
    UserAction(_.P03).async { implicit req =>
      _customers.find(Customer.ID(customer_id)).map { customer =>
        Ok(html.customers.invoice(customer, pager))
      }.recover {
        case e: BaseException => NotFound
      }
    }
  }
}

object CustomersCtrl
  extends CustomerCanonicalNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** Access : Index Our Customers */
    val P16 = Access.Pos(16)
    /** Access : Index HRs */
    val P17 = Access.Pos(17)
    /** Access : Index Orders */
    val P18 = Access.Pos(18)
    /** Access : Index Contracts */
    val P19 = Access.Pos(19)
    /** Access : Index Preferences */
    val P20 = Access.Pos(20)
    /** Access : Index Invoice */
    val P21 = Access.Pos(21)

    def values = Seq(P00, P03, P04, P16, P17, P18, P19, P20, P21)
  }

  object AccessDef extends AccessDef
}