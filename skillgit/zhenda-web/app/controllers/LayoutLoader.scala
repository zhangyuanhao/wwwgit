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
import play.api.mvc._
import security._

import scala.concurrent._
import scala.util._

/**
 * @author zepeng.li@factchina.com
 */
case class LayoutLoader(
  implicit
  val basicPlayApi: BasicPlayApi,
  val _groups: Groups
) extends ActionTransformer[UserOptRequest, UserOptRequest]
  with BasicPlayComponents
  with UsersComponents
  with InternalGroupsComponents
  with DefaultPlayExecutor
  with I18nLoggingComponents {

  def loadLayoutOf(user: User): Future[User] =
    _groups.findLayouts(user.groups).map { layouts =>
      val list = layouts.collect {
        case (gid, layout) if layout.isDefined => layout.get
      }
      user.copy(attributes = user.attributes + ("layouts" -> list))
    }

  override protected def transform[A](
    request: UserOptRequest[A]
  ): Future[UserOptRequest[A]] = request match {
    case UserOptRequest(Success(user), inner) =>
      loadLayoutOf(user).map {
        u => UserOptRequest(Success(u), inner)
      }.andThen {
        case Failure(e: BaseException) => Logger.debug(s"LayoutLoader failed, because ${e.reason}", e)
        case Failure(e: Throwable)     => Logger.error(s"LayoutLoader failed.", e)
      }.recover {
        case _: Throwable => request
      }
    case _                                    => Future.successful(request)
  }

}