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

import elasticsearch.ElasticSearch
import helpers._
import models._
import models.cfs.CassandraFileSystem.Role
import models.cfs._
import models.misc._
import play.api.data.Form
import play.api.data.Forms._
import play.api.http.HttpConfiguration
import play.api.i18n.I18nSupport
import play.api.libs.MimeTypes
import play.api.libs.crypto.CookieSigner
import play.api.mvc._
import security._
import services._
import views._

import scala.concurrent.Future

/**
 * @author zepeng.li@factchina.com
 */
class MyCtrl(
  val httpConfiguration: HttpConfiguration,
  val cookieSigner: CookieSigner
)(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val _persons: Persons,
  val _cfs: CassandraFileSystem,
  val bandwidth: BandwidthService,
  val es: ElasticSearch
) extends UserCanonicalNamed
  with CheckedModuleName
  with Controller
  with security.Session
  with BasicPlayComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with MaybeUserActionComponents
  with UserActionComponents[MyCtrl]
  with UsersCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with CanonicalNameBasedMessages
  with BandwidthConfigComponents
  with CFSImageComponents
  with I18nSupport
  with I18nLoggingComponents {

  val ChangePasswordFM = Form[ChangePasswordFD](
    mapping(
      "old_password" -> Password.constrained,
      "new_password" -> mapping(
        "original" -> Password.constrained,
        "confirmation" -> text
      )(Password.Confirmation.apply)(Password.Confirmation.unapply).verifying()
    )(ChangePasswordFD.apply)(ChangePasswordFD.unapply)
  )

  case class ChangePasswordFD(
    old_password: Password,
    new_password: Password.Confirmation
  )

  val ProfileFM = Form(
    tuple(
      "first_name" -> PersonalName.Part.constrained,
      "last_name" -> PersonalName.Part.constrained
    )
  )

  def dashboard =
    (MaybeUserAction() andThen AuthChecker()) { implicit req =>
      Ok(html.my.dashboard())
    }

  def account =
    (MaybeUserAction() andThen AuthChecker()) { implicit req =>
      Ok(html.my.account(ChangePasswordFM))
    }

  def changePassword =
    (MaybeUserAction() andThen AuthChecker()).async { implicit req =>

      val bound = ChangePasswordFM.bindFromRequest()
      bound.fold(
        failure =>
          Future.successful {
            BadRequest(html.my.account(bound))
          },
        success => {
          if (!success.new_password.isConfirmed)
            Future.successful {
              BadRequest(
                html.my.account(
                  bound.withGlobalError(message("password.not.confirmed"))
                )
              )
            }
          else if (!req.user.hasPassword(success.old_password))
            Future.successful {
              BadRequest(
                html.my.account(
                  bound.withGlobalError(message("old.password.invalid"))
                )
              )
            }
          else
            req.user.updatePassword(
              success.new_password.original
            ).flatMap { user =>
              Redirect(routes.MyCtrl.account()).flashing {
                AlertLevel.Info -> message("password.changed")
              }.createSession(user, rememberMe = false)
            }
        }
      )
    }

  def profile =
    (MaybeUserAction() andThen AuthChecker()).async { implicit req =>
      _persons.find(req.user.id).map { p =>
        Ok(html.my.profile(filledWith(p)))
      }.recover {
        case e: Person.NotFound =>
          Ok(html.my.profile(ProfileFM))
      }
    }

  def changeProfile =
    (MaybeUserAction() andThen AuthChecker()).async { implicit req =>
      val bound = ProfileFM.bindFromRequest()

      bound.fold(
        failure => Future.successful {
          BadRequest(html.my.profile(failure))
        }, {
          case (first, last) =>
            for {
              p <- Future.successful(Person(req.user.id, PersonalName(last, first)))
              _ <- _persons.save(p)
              _ <- es.Index(p) into _persons
            } yield {
              Ok(html.my.profile(filledWith(p)))
            }
        }
      )
    }

  def filledWith(p: Person) =
    ProfileFM.fill(
      p.personal_name.first,
      p.personal_name.last
    )

  val profileImageFileName = "profile.png"

  val profileImageMaxLength: Int = configuration
    .getBytes(s"$canonicalName.profile.image.max.length").map(_.toInt)
    .getOrElse(2 * 1000 * 1000)

  def profileImage(size: Int) =
    (MaybeUserAction() andThen AuthChecker()).async { req =>
      CFSImage.show(
        filePath = u => Path.home(u) + profileImageFileName,
        size = size
      ).apply(req).recoverWith {
        case _ => Assets.at("/public", "images/profile_male.svg").apply(req)
      }
    }

  def testProfileImage =
    (MaybeUserAction() andThen AuthChecker()).async {
      CFSImage.test(
        filePath = u => Path.home(u) + profileImageFileName
      )
    }

  def uploadProfileImage =
    UserUploadingToCFS(_.P16)(Path.home(_)) {
      CFSImage.upload(
        filePath = u => Path.home(u) + profileImageFileName,
        permission = Role.owner.rw + Role.other.r,
        overwrite = true,
        maxLength = profileImageMaxLength,
        accept = MyCtrl.acceptProfileImageFormats
      )
    }
}

object MyCtrl {

  def acceptProfileImageFormats =
    Seq("*.png", "*.jpg", "*.gif").flatMap(MimeTypes.forFileName)

}