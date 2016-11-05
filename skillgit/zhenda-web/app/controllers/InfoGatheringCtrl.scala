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

import controllers.api_internal.InfoGatheringCNamed
import helpers._
import models._
import models.business.customers._
import models.business.infogathering._
import models.cfs.CassandraFileSystem._
import models.cfs._
import play.api.i18n._
import play.api.libs.MimeTypes
import play.api.mvc._
import security._
import services._
import services.actors._
import views._

import scala.concurrent.Future

/**
 * @author zepeng.li@factchina.com
 */
class InfoGatheringCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _expirableLinks: ExpirableLinks,
  val _orders: Orders,
  val _cfs: CassandraFileSystem,
  val bandwidth: BandwidthService,
  val fopService: FOPService
) extends InfoGatheringCNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with UserActionRequiredComponents
  with PAMBuilderComponents
  with MaybeUserActionComponents
  with UserActionComponents[InfoGatheringCtrl.AccessDef]
  with InfoGatheringCtrl.AccessDef
  with ExceptionHandlers
  with UsersComponents
  with CandidateRegionComponents
  with AkkaTimeOutConfig
  with DefaultPlayExecutor
  with BandwidthConfigComponents
  with AuthorizationLetterComponents
  with CFSImageComponents
  with I18nLoggingComponents
  with I18nSupport {

  implicit lazy val pamBuilder: BasicPlayApi => PAM = {
    AuthenticateByExpirableLink(_groups, _expirableLinks)
  }

  /**
   * Show information gathering form corresponding to an order, only if
   * the user got a valid link in his mail inbox.
   */
  def show(id: String) = {
    MaybeUserAction().async { implicit req =>
      (for {
        oid <- _expirableLinks.find(id).map(_.target_id)
        passed <- (_candidate(oid) ? (_.CheckStatus())).mapTo[Boolean]
      } yield {
        val token = AuthenticateByExpirableLink.encrypt(id, oid)
        Ok(html.infogathering.show(id, token))
      }).recover {
        case e: Order.WrongAction      => Redirect(controllers.routes.Application.index())
        case e: ExpirableLink.NotFound => Redirect(controllers.routes.Application.index())
        case e: Order.NotFound         => Redirect(controllers.routes.Application.index())
        case e: BaseException          => Redirect(controllers.routes.Application.index())
      }
    }
  }

  def parts(sub_path: String) =
    (UserAction(_.P02) andThen CandidateChecker()).apply { implicit req =>
      sub_path match {
        case "identity"      => Ok(html.infogathering._identity_input())
        case "education"     => Ok(html.infogathering._education_input())
        case "prl"           => Ok(html.infogathering._professional_license_input())
        case "employment"    => Ok(html.infogathering._employment_input())
        case "authorization" => Ok(html.infogathering._authorization_input())
      }
    }

  def testImage =
    (UserAction(_.P05) andThen CandidateChecker()).async {
      CFSImage.test(filePath = u => Path.home(u))
    }

  def uploadImage(filename: String) =
    UserUploadingToCFS(_.P05)(
      Path.home(_), CandidateChecker.Parser()
    ) {
      CFSImage.upload(
        filePath = u => Path.home(u) + s"$filename.png",
        permission = Role.owner.rw + Role.group(InternalGroup.Employees).r,
        overwrite = true,
        maxLength = imageMaxLength,
        accept = InfoGatheringCtrl.acceptImageFormats
      )
    }

  def image(filename: String, size: Int) =
    (UserAction(_.P05) andThen CandidateChecker()).async {
      CFSImage.show(filePath = u => Path.home(u) + filename, size)
    }

  lazy val imageMaxLength: Int = configuration
    .getBytes(s"$canonicalName.upload.image.max.length").map(_.toInt)
    .getOrElse(5 * 1000 * 1000)

  def showAuthorizationPDF(
    form_id: String,
    blank: Option[Boolean],
    inline: Option[Boolean]
  ) = {
    (UserAction(_.P16) andThen CandidateChecker()).async { implicit req =>
      for {
        oid <- _expirableLinks.find(form_id).map(_.target_id)
        form <- {
          if (blank.contains(false)) {
            (_candidate(oid) ? (_.GetSaved())).mapTo[InfoGatheringForm]
          } else {
            (_candidate(oid) ? (_.GetBlankForm())).mapTo[InfoGatheringForm]
          }
        }
        result <- {
          generatePDFFrom(form, inline, NotFound)
        }
      } yield result
    }
  }

  /**
   * 订单状态检查
   */
  object CandidateChecker {

    def apply()(
      implicit
      eh: UserActionExceptionHandler
    ) = new ActionFilter[UserRequest] {
      override protected def filter[A](
        req: UserRequest[A]
      ): Future[Option[Result]] = {
        (_candidate(req.user.id) ? (_.CheckStatus())).mapTo[Boolean].map {
          case true  => None
          case false => Some(eh.onUnauthorized(req))
        }.recover {
          case e: Order.WrongAction => Some(eh.onUnauthorized(req))
        }
      }
    }

    def Parser()(
      implicit
      _basicPlayApi: BasicPlayApi,
      eh: BodyParserExceptionHandler
    ) = new BodyParserFilter[UserRequestHeader]
      with BodyParserFunctionComponents {
      override protected def filter[B](
        req: UserRequestHeader
      ): Future[Option[BodyParser[B]]] = {
        (_candidate(req.user.id) ? (_.CheckStatus())).mapTo[Boolean].map {
          case true  => None
          case false => onSome(eh.onUnauthorized(req))
        }.recover {
          case e: Order.WrongAction => onSome(eh.onUnauthorized(req))
        }
      }
      def basicPlayApi = _basicPlayApi
    }
  }

  def showS(id: String) = show(id)
  def showL(id: String) = show(id)
}

object InfoGatheringCtrl
  extends InfoGatheringCNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** 生成授权书PDF */
    val P16 = Access.Pos(16)

    def values = Seq(P02, P05, P16)
  }

  object AccessDef extends AccessDef

  def acceptImageFormats =
    Seq("*.png", "*.jpg", "*.jpeg").flatMap(MimeTypes.forFileName)
}