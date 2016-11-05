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

import controllers.CFSBodyParser._
import helpers._
import models._
import models.business.customers.Orders
import models.business.infogathering._
import models.business.providers._
import models.cfs.CassandraFileSystem.Role
import models.cfs._
import play.api.i18n.I18nSupport
import play.api.libs.MimeTypes
import play.api.mvc._
import protocols.JsonProtocol.JsonMessage
import protocols._
import security._
import services._
import services.actors._
import views.html

import scala.concurrent.Future
import scala.util._

/**
 * @author yi.liu@factchina.com
 */
class EmployeeOrdersCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val bandwidth: BandwidthService,
  val _cfs: CassandraFileSystem,
  val _orders: Orders,
  val _employees: Employees,
  val fopService: FOPService
) extends EmployeeOrdersCNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with EmployeeActionComponents[EmployeeOrdersCtrl.AccessDef]
  with UserActionComponents[EmployeeOrdersCtrl.AccessDef]
  with EmployeeOrdersCtrl.AccessDef
  with ExceptionHandlers
  with TaskProcessorRegionComponents
  with OrderProcessorRegionComponents
  with AuthorizationLetterComponents
  with AkkaTimeOutConfig
  with DefaultPlayExecutor
  with BandwidthConfigComponents
  with CFSStreamComponents
  with CFSImageComponents
  with I18nLoggingComponents
  with I18nSupport {

  def index =
    EmployeeAction(_.P03).async { implicit req =>
      _employees.infos.find(req.employee).map { e =>
        val task_type = Task.Type.values.map(_.underscore)
        e.roles.toBitSet.toIndices.headOption match {
          case Some(i) => Ok(html.employee_orders.index(s"""/${task_type(i)}/customer_complained"""))
          case _       => Ok(html.employee_orders.index("/"))
        }
      }
    }

  def parts(sub: String) =
    EmployeeAction(_.P03).apply { implicit req =>
      sub match {
        // side bar
        case "support_side_bar"       => Ok(html.employee_orders._support_side_bar())
        case "review_side_bar"        => Ok(html.employee_orders._review_side_bar())
        case "qualification_side_bar" => Ok(html.employee_orders._qualification_side_bar())
        case "employment_side_bar"    => Ok(html.employee_orders._employment_side_bar())
        // 客服
        case "support_customer_complained" => Ok(html.employee_orders.parts._support_customer_complained())
        case "support_basically_completed" => Ok(html.employee_orders.parts._support_basically_completed())
        case "support_finally_completed"   => Ok(html.employee_orders.parts._support_finally_completed())
        case "partially_assigned"          => Ok(html.employee_orders.parts._partially_assigned())
        case "fully_assigned"              => Ok(html.employee_orders.parts._fully_assigned())
        case "customer_order_index"        => Ok(html.employee_orders.parts._customer_order_index())
        // 调查员
        case "investigator_customer_complained" => Ok(html.employee_orders.parts._investigator_customer_complained())
        case "investigator_review_requested"    => Ok(html.employee_orders.parts._investigator_review_requested())
        case "candidate_submitted"              => Ok(html.employee_orders.parts._candidate_submitted())
        case "review_finally_passed"            => Ok(html.employee_orders.parts._review_finally_passed())
        case "list_history_tasks"               => Ok(html.employee_orders.parts._list_history_tasks())
        // 资质调查员
        case "qualification_awaiting_submission" => Ok(html.employee_orders.parts._qualification_awaiting_submission())
        // 履历调查员
        case "employment_awaiting_submission" => Ok(html.employee_orders.parts._employment_awaiting_submission())
        case "unassigned"                     => Ok(html.employee_orders.parts._unassigned())
        // 审核员
        case "review_customer_complained" => Ok(html.employee_orders.parts._review_customer_complained())
        case "review_review_requested"    => Ok(html.employee_orders.parts._review_review_requested())
        case "awaiting_review_request"    => Ok(html.employee_orders.parts._awaiting_review_request())
        case "review_basically_completed" => Ok(html.employee_orders.parts._review_basically_completed())
        case "review_finally_completed"   => Ok(html.employee_orders.parts._review_finally_completed())
        case "review_unassigned"          => Ok(html.employee_orders.parts._unassigned_with_task())
      }
    }

  def history(id: UUID, task_type: String) =
    EmployeeAction(_.P02).async { implicit req =>
      _orders.find(id).map { o =>
        Ok(html.employee_orders.history(id, task_type, o.purchased_services))
      }
    }

  def testAudio(order_id: UUID) =
    EmployeeAction(_.P16).async { implicit req =>
      FlowJs().bindFromQueryString.test(Path.root / order_id)
    }

  def uploadAudio(order_id: UUID, task_id: UUID, filename: String) = {
    val path = Path.root / order_id
    EmployeeUploadingToCFS(_.P16)(
      _ => path, FileUploadableChecker(task_id)
    ) { implicit req =>
      (req.body.file("file").map(_.ref) match {
        case Some(file) => FlowJs(
          filename = Some(filename),
          permission = Role.owner.rw + Role.group(InternalGroup.Employees).r,
          overwrite = true,
          maxLength = audioMaxLength,
          accept = EmployeeOrdersCtrl.acceptAudioFormats
        ).bindFromRequestBody.upload(file, path) { (curr, file) =>
          Future {
            val param = Task.Action.Param(req.employee, comment = Some(filename))
            _taskProcessor(task_id) ! (_.FileUpload(param))
          }
        }
        case None       => throw CFSBodyParser.MissingFile()
      }).andThen {
        case Failure(e: CFSBodyParser.MissingFile)      => Logger.warn(e.reason)
        case Failure(e: FileSystemAccessControl.Denied) => Logger.debug(e.reason)
        case Failure(e: BaseException)                  => Logger.error(e.reason)
      }.recover {
        case e: BaseException => NotFound(JsonMessage(e))
      }
    }
  }

  def streamAudio(order_id: UUID, filename: String) =
    EmployeeAction(_.P17).async { implicit req =>
      val path = Path.root / order_id + filename
      CFSHttpCaching(path) apply (HttpStreamResult.stream(_))
    }

  def testImage(order_id: UUID) =
    EmployeeAction(_.P19).async { implicit req =>
      CFSImage.test(filePath = u => Path.root / order_id)(req)
    }

  def uploadImage(order_id: UUID, task_id: UUID, filename: String) = {
    val path = Path.root / order_id
    EmployeeUploadingToCFS(_.P19)(
      _ => path, FileUploadableChecker(task_id)
    ) {
      CFSImage.upload(
        filePath = u => path + s"$filename.png",
        permission = Role.owner.rw + Role.group(InternalGroup.Employees).r,
        overwrite = true,
        maxLength = imageMaxLength,
        accept = EmployeeOrdersCtrl.acceptImageFormats
      )
    }
  }

  def image(order_id: UUID, filename: String, size: Int) =
    EmployeeAction(_.P18).async { implicit req =>
      CFSImage.show(filePath = u => Path.root / order_id + filename, size)(userActionExceptionHandler)(req)
    }

  def originImage(order_id: UUID, filename: String, size: Int) =
    EmployeeAction(_.P18).async { implicit req =>
      CFSHttpCaching(Path.root / order_id + filename) apply (HttpStreamResult.stream(_))
    }

  def testAttachment(order_id: UUID) =
    EmployeeAction(_.P19).async { implicit req =>
      FlowJs().bindFromQueryString.test(Path.root / order_id)
    }

  def uploadAttachment(order_id: UUID, task_id: UUID, filename: String) = {
    val path = Path.root / order_id + filename
    EmployeeUploadingToCFS(_.P19)(
      _ => path.parent, FileUploadableChecker(task_id)
    ) { implicit req =>
      (req.body.file("file").map(_.ref) match {
        case Some(chunk) => FlowJs(
          filename = path.filename,
          permission = Role.owner.rw + Role.group(InternalGroup.Employees).r,
          overwrite = true,
          maxLength = attachmentMaxLength
        ).bindFromRequestBody.upload(chunk, path.parent)()
        case None        => throw CFSBodyParser.MissingFile()
      }).andThen {
        case Failure(e: MissingFile) => Logger.warn(e.reason, e)
      }.recover {
        case e: CFSBodyParser.MissingFile => Results.BadRequest(JsonMessage(e))
      }
    }
  }

  def attachment(order_id: UUID, filename: String) =
    EmployeeAction(_.P18).async { implicit req =>
      CFSHttpCaching(Path.root / order_id + filename) apply (HttpDownloadResult.send(_, inline = false))
    }

  lazy val imageMaxLength: Int = configuration
    .getBytes(s"$canonicalName.upload.image.max.length").map(_.toInt)
    .getOrElse(5 * 1000 * 1000)

  lazy val attachmentMaxLength: Int = configuration
    .getBytes(s"$canonicalName.upload.attachment.max.length").map(_.toInt)
    .getOrElse(10 * 1000 * 1000)

  lazy val audioMaxLength: Int = configuration
    .getBytes(s"$canonicalName.upload.audio.max.length").map(_.toInt)
    .getOrElse(50 * 1000 * 1000)

  /**
   * 显示订单中候选人提交信息得授权书
   */
  def showAuthorizationPDF(order_id: UUID, inline: Option[Boolean]) =
  EmployeeAction(_.P20).async { implicit req =>
    (_orderProcessor(order_id) ? {
      _.InfoGatheringForm.GetAuthorization(req.employee)
    }).mapTo[AuthorizationSection].flatMap { s =>
      generateAuthorizationPDF(Some(s), inline, NotFound)
    }
  }

  case class FileUploadableChecker(task_id: UUID)(
    implicit
    val basicPlayApi: BasicPlayApi,
    val eh: BodyParserExceptionHandler
  ) extends BodyParserFilter[EmployeeRequestHeader]
    with BodyParserFunctionComponents {

    override protected def filter[B](
      req: EmployeeRequestHeader
    ): Future[Option[BodyParser[B]]] = {
      (_taskProcessor(task_id) ? (_.IsFileUploadable(req.employee))).mapTo[Boolean].map {
        case true  => None
        case false => onSome(eh.onPermissionDenied(req))
      }.recover {
        case e: Task.WrongAction => onSome(eh.onPermissionDenied(req))
      }
    }
  }
}

object EmployeeOrdersCtrl
  extends EmployeeOrdersCNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** Access : Upload mp3 */
    val P16 = Access.Pos(16)
    /** Access : Download mp3 */
    val P17 = Access.Pos(17)
    /** Access : Download image */
    val P18 = Access.Pos(18)
    /** Access : 上传补查资料 */
    val P19 = Access.Pos(19)
    /** Access : 生成授权书PDF文档 */
    val P20 = Access.Pos(20)

    def values = Seq(P02, P03, P16, P17, P18, P19, P20)
  }

  object AccessDef extends AccessDef

  def acceptAudioFormats =
    Seq("*.mp3").flatMap(MimeTypes.forFileName)

  def acceptImageFormats =
    Seq("*.png", "*.jpg", "*.jpeg").flatMap(MimeTypes.forFileName)
}