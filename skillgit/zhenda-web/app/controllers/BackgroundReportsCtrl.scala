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

import akka.stream.scaladsl._
import akka.util._
import helpers._
import models.business.checks._
import models.business.customers._
import models.business.providers._
import models.business.reports._
import models.business.services._
import play.api.libs.json._
import play.api.mvc._
import protocols._
import security._
import services._
import services.actors._
import views._

import scala.concurrent._

/**
 * @author zepeng.li@factchina.com
 */
class BackgroundReportsCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _bgReports: BackgroundReports,
  val _orders: Orders,
  val _tasks: Tasks,
  val fopService: FOPService
) extends BackgroundReportCNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[BackgroundReportsCtrl.AccessDef]
  with MaybeUserActionComponents
  with BackgroundReportsCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with BackgroundReportProcessorRegionComponents
  with AppConfigComponents
  with AkkaTimeOutConfig {

  /**
   * 显示Html版报告
   *
   * @param id 报告(订单)id
   */
  def show(id: UUID) = {
    UserAction(_.P02).async { implicit req =>
      (_reportProcessor(id) ? (_.Get())).mapTo[BackgroundReport].map { report =>
        implicit val msg = report.messages()
        Ok(html.reports.show(report))
      }
    }
  }

  /**
   * 显示PDF版报告
   *
   * @param id     报告(订单)id
   * @param inline 使用用浏览器打开
   */
  def showPDF(id: UUID, inline: Option[Boolean]) = {
    UserAction(_.P02).async { implicit req =>
      for {
        order <- _orders.find(id)
        report <- (_reportProcessor(id) ? (_.Get())).mapTo[BackgroundReport]
        pdf <- generatePDF(report, order)
      } yield {
        HttpDownloadResult.send(pdf, inline = inline.contains(true))
      }
    }
  }

  /**
   * 无需登录查看报告
   * TODO 在完全推广账号后删除route和接口
   */
  def showWithoutLogin(id: UUID) = {
    MaybeUserAction().async { implicit req =>
      (_reportProcessor(id) ? (_.Get())).mapTo[BackgroundReport].map { report =>
        implicit val msg = report.messages()
        Ok(html.reports.show(report))
      }
    }
  }

  /**
   * 预览Html版报告
   */
  def preview(id: UUID, review_pass_all: Option[Boolean]) = {
    UserAction(_.P16).async { implicit req =>
      for {
        (report, _) <- buildTempReport(id, review_pass_all)
      } yield {
        implicit val msg = report.messages()
        Ok(html.reports.preview(report))
      }
    }
  }

  /**
   * 预览PDF版报告
   */
  def previewPDF(
    id: UUID,
    review_pass_all: Option[Boolean],
    inline: Option[Boolean]
  ) = {
    UserAction(_.P16).async { implicit req =>
      for {
        (report, order) <- buildTempReport(id, review_pass_all)
        pdf <- generatePDF(report, order)
      } yield {
        HttpDownloadResult.send(pdf, inline = inline.contains(true))
      }
    }
  }


  /**
   * 生成可下载的PDF版报告
   */
  def generatePDF(report: BackgroundReport, order: Order) = {
    implicit val msg = report.messages()
    import fo.pdf.reports
    for {
      bytes <- fopService.toPDF(
        userAgent = FOPService.UserAgent(
          title = Some(reports.metadata.title(report, order.status)),
          subject = Some(reports.metadata.subject(report, order.status)),
          author = config.getString("pdf.author"),
          producer = config.getString("pdf.producer"),
          creator = config.getString("pdf.creator"),
          creation_date = Some(report.updated_at),
          keywords = reports.metadata.keywords(report, order.status)
        ),
        document = reports.report(report)
      )
    } yield new HttpDownloadable {
      def size = bytes.length
      def name = reports.metadata.filename(report, order.status)
      def whole = Source.single(ByteString.fromArray(bytes))
    }
  }

  /**
   * 从Task内容构建制作中报告
   *
   * @param id              报告(订单)id
   * @param review_pass_all 是否设置所有审核通过为true
   * @return 制作中报告
   */
  def buildTempReport(id: UUID, review_pass_all: Option[Boolean]) = {
    for {
      order <- _orders.find(id)
      tasks <- Future.traverse(order.tasks.values)(_tasks.find)
      content <- Future.successful {
        tasks.map(_.content)
          .reduceOption(_ ++ _)
          .getOrElse(ChecksSet.default)
      }
    } yield {
      val report = BackgroundReport(
        order.id,
        order.content.langs,
        order.customer,
        order.provider,
        order.candidate_info,
        if (!review_pass_all.contains(true)) content
        else forcePass(content)
      )
      (report, order)
    }
  }

  /**
   * 把ChecksSet里所有review_result.passed替换成true
   */
  private def forcePass(cs: ChecksSet): ChecksSet = {
    val replacement = s""""passed":true"""
    val js = Json.toJson(cs).toString
      .replace(s""""passed":null""", replacement)
      .replace(s""""passed":false""", replacement)

    Json.fromJson[ChecksSet](Json.parse(js)).getOrElse(ChecksSet.default)
  }
}

object BackgroundReportsCtrl
  extends BackgroundReportCNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** Access : Preview Report */
    val P16 = Access.Pos(16)

    def values = Seq(P02, P16)
  }

  object AccessDef extends AccessDef

  /**
   * 取得Panel的class
   *
   * @param result panel内部内容的风险级别
   * @param passed panel内部内容是否通过审核
   * @return
   */
  def getPanelType(
    result: Option[Level],
    passed: Option[Boolean],
    remaining: Boolean
  ) = passed match {
    case Some(true) =>
      remaining match {
        case true => "panel-default"
        case _    =>
          result match {
            case Some(Level.A)   => "panel-success"
            case Some(Level.A10) => "panel-success"
            case Some(Level.A20) => "panel-success"
            case Some(Level.B)   => "panel-info"
            case Some(Level.C)   => "panel-warning"
            case Some(Level.D)   => "panel-danger"
            case None            => "panel-default"
            case _               => "panel-default"
          }
      }
    case _          => "panel-default"
  }

  /**
   * 取得该模块是否显示的flag
   *
   * @param result 风险级别
   * @param passed 是否通过审核
   * @return
   */
  def showOrNot(
    result: Option[Level],
    passed: Option[Boolean] = Some(true)
  ) = passed match {
    case Some(true) =>
      result match {
        case Some(Level.A)       => "false"
        case Some(Level.A10)     => "false"
        case Some(Level.Na)      => "false"
        case Some(Level.Unknown) => "false"
        case None                => "false"
        case _                   => "true"
      }
    case _          => "false"
  }
}