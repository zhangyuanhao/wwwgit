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

import models._
import models.cfs.{CassandraFileSystem => CFS, _}
import play.api.mvc._
import security.ModulesAccessControl._
import security._
import services._

import scala.concurrent._
import scala.language.{higherKinds, postfixOps}

/**
 * @author zepeng.li@factchina.com
 */
trait CustomerUserActionComponents[T <: BasicAccessDef] {
  self: T
    with UserActionRequiredComponents
    with UserActionComponents[T]
    with ExceptionHandlers =>

  def CustomerUserAction(specifiers: (T => Access.Pos)*): ActionBuilder[CustomerUserRequest] = {
    val access = Access.union(specifiers.map(_ (this).toAccess))
    CustomerUserAction0(access, EmptyActionFunction[CustomerUserRequest]())
  }

  def CustomerUserUploadingToCFS(
    specifiers: (T => Access.Pos)*
  )(
    path: User => Path,
    otherParserChecker: BodyParserFunction[CustomerUserRequestHeader, CustomerUserRequestHeader] = EmptyBodyParserFunction[CustomerUserRequestHeader](),
    otherActionChecker: ActionFunction[CustomerUserRequest, CustomerUserRequest] = EmptyActionFunction[CustomerUserRequest](),
    dirPermission: CFS.Permission = CFS.Role.owner.rwx
  )(
    block: CustomerUserRequest[MultipartFormData[File]] => Future[Result]
  )(
    implicit
    _cfs: CFS,
    bandwidth: BandwidthService,
    bandwidthConfig: BandwidthConfig
  ): Action[MultipartFormData[File]] = {
    CustomerUserAction10[CustomerUserRequestHeader, CustomerUserRequest, MultipartFormData[File]](
      Access.union(specifiers.map(_ (this).toAccess)),
      otherParserChecker = otherParserChecker,
      otherActionChecker = otherActionChecker,
      parser = req => CFSBodyParser(path, dirPermission).parser(req)(req.user),
      method = block
    )
  }

  def CustomerUserAction10[P, Q[_], A](
    access: Access,
    otherParserChecker: BodyParserFunction[CustomerUserRequestHeader, P],
    otherActionChecker: ActionFunction[CustomerUserRequest, Q],
    parser: P => Future[BodyParser[A]],
    method: Q[A] => Future[Result]
  ): Action[A] = {
    CustomerUserAction1(access, otherActionChecker).async(
      CustomerUserBodyParser0(access, otherParserChecker).async(parser)
    )(method)
  }

  def CustomerUserBodyParser0[P](
    access: Access,
    otherParserChecker: BodyParserFunction[CustomerUserRequestHeader, P]
  ): BodyParserBuilder[P] = {
    UserBodyParser0(access, CustomerUserChecker.Parser() andThen otherParserChecker)
  }

  def CustomerUserAction0[P[_]](
    access: Access,
    otherActionChecker: ActionFunction[CustomerUserRequest, P]
  ): ActionBuilder[P] = {
    UserAction0(access, CustomerUserChecker() andThen otherActionChecker)
  }

  def CustomerUserAction1[P[_]](
    access: Access,
    otherActionChecker: ActionFunction[CustomerUserRequest, P]
  ): ActionBuilder[P] = {
    UserAction1(access, CustomerUserChecker() andThen otherActionChecker)
  }
}