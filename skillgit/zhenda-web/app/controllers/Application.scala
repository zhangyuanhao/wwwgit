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

import helpers._
import models._
import models.cfs.Path
import play.api.i18n._
import play.api.mvc._
import security._
import views._

import scala.util._

class Application(
  implicit
  val basicPlayApi: BasicPlayApi,
  val _groups: Groups
) extends Controller
  with CanonicalNamed
  with BasicPlayComponents
  with UsersComponents
  with AuthenticateBySessionComponents
  with MaybeUserActionComponents
  with ExceptionHandlers
  with AppConfigComponents
  with ViewMessages
  with I18nSupport {

  override val basicName = "app"

  def index = MaybeUserAction().apply { implicit req =>
    req.maybeUser match {
      case Success(u) => Redirect(routes.MyCtrl.dashboard())
      case _          => Ok(html.welcome.index())
    }
  }

  def about = MaybeUserAction().apply { implicit req =>
    Ok(html.static_pages.about())
  }

  def wiki = MaybeUserAction().apply { implicit req =>
    val videoPath = config.getString("wiki.video").map(fn => Path(filename = Some(fn)))
    Ok(html.static_pages.wiki(videoPath))
  }
}