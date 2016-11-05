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
trait EmployeeActionComponents[T <: BasicAccessDef] {
  self: T
    with UserActionRequiredComponents
    with UserActionComponents[T]
    with ExceptionHandlers =>

  def EmployeeAction(specifiers: (T => Access.Pos)*): ActionBuilder[EmployeeRequest] = {
    val access = Access.union(specifiers.map(_ (this).toAccess))
    EmployeeAction0(access, EmptyActionFunction[EmployeeRequest]())
  }

  def EmployeeUploadingToCFS(
    specifiers: (T => Access.Pos)*
  )(
    path: User => Path,
    otherParserChecker: BodyParserFunction[EmployeeRequestHeader, EmployeeRequestHeader] = EmptyBodyParserFunction[EmployeeRequestHeader](),
    otherActionChecker: ActionFunction[EmployeeRequest, EmployeeRequest] = EmptyActionFunction[EmployeeRequest](),
    dirPermission: CFS.Permission = CFS.Role.owner.rwx
  )(
    block: EmployeeRequest[MultipartFormData[File]] => Future[Result]
  )(
    implicit
    _cfs: CFS,
    bandwidth: BandwidthService,
    bandwidthConfig: BandwidthConfig
  ): Action[MultipartFormData[File]] = {
    EmployeeAction10[EmployeeRequestHeader, EmployeeRequest, MultipartFormData[File]](
      Access.union(specifiers.map(_ (this).toAccess)),
      otherParserChecker = otherParserChecker,
      otherActionChecker = otherActionChecker,
      parser = req => CFSBodyParser(path, dirPermission).parser(req)(req.user),
      method = block
    )
  }

  def EmployeeAction10[P, Q[_], A](
    access: Access,
    otherParserChecker: BodyParserFunction[EmployeeRequestHeader, P],
    otherActionChecker: ActionFunction[EmployeeRequest, Q],
    parser: P => Future[BodyParser[A]],
    method: Q[A] => Future[Result]
  ): Action[A] = {
    EmployeeAction1(access, otherActionChecker).async(
      EmployeeBodyParser0(access, otherParserChecker).async(parser)
    )(method)
  }

  def EmployeeBodyParser0[P](
    access: Access,
    otherParserChecker: BodyParserFunction[EmployeeRequestHeader, P]
  ): BodyParserBuilder[P] = {
    UserBodyParser0(access, EmployeeChecker.Parser() andThen otherParserChecker)
  }

  def EmployeeAction0[P[_]](
    access: Access,
    otherActionChecker: ActionFunction[EmployeeRequest, P]
  ): ActionBuilder[P] = {
    UserAction0(access, EmployeeChecker() andThen otherActionChecker)
  }

  def EmployeeAction1[P[_]](
    access: Access,
    otherActionChecker: ActionFunction[EmployeeRequest, P]
  ): ActionBuilder[P] = {
    UserAction1(access, EmployeeChecker() andThen otherActionChecker)
  }
}