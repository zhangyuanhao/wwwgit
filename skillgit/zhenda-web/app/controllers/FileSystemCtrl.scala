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
import models.cfs._
import models.misc._
import play.api.i18n._
import play.api.mvc.Controller
import protocols._
import security._
import services._
import views._

/**
 * @author zepeng.li@factchina.com
 */
class FileSystemCtrl(
  implicit
  val basicPlayApi: BasicPlayApi,
  val userActionRequired: UserActionRequired,
  val bandwidth: BandwidthService,
  val _cfs: CassandraFileSystem
) extends CassandraFileSystemCanonicalNamed
  with CheckedModuleName
  with Controller
  with BasicPlayComponents
  with InternalGroupsComponents
  with AuthenticateBySessionComponents
  with UserActionRequiredComponents
  with UserActionComponents[FileSystemCtrl.AccessDef]
  with FileSystemCtrl.AccessDef
  with ExceptionHandlers
  with DefaultPlayExecutor
  with BandwidthConfigComponents
  with CFSStreamComponents
  with I18nSupport {

  def index(path: Path, pager: Pager) =
    UserAction(_.P03, _.P02, _.P01, _.P06).async { implicit req =>
      for {
        internalGroups <- _groups.find(_internalGroups.InternalGroupIds)
      } yield {
        Ok(html.file_system.index(path, pager, internalGroups))
      }
    }

  def show(path: Path) =
    UserAction(_.P02, _.P01, _.P06).async { implicit req =>
      (for {
        file <- _cfs.file(path)
      } yield file).map { file =>
        Ok(html.file_system.show(file))
      }.recover {
        case e: FileSystemAccessControl.Denied => Forbidden
      }
    }

  def download(path: Path, inline: Boolean) =
    UserAction(_.P16).async { implicit req =>
      CFSHttpCaching(path) apply (HttpDownloadResult.send(_, inline = inline))
    }

  def stream(path: Path) =
    UserAction(_.P16).async { implicit req =>
      CFSHttpCaching(path) apply (HttpStreamResult.stream(_))
    }
}

object FileSystemCtrl
  extends CassandraFileSystemCanonicalNamed
    with PermissionCheckable
    with CanonicalNameBasedMessages
    with ViewMessages {

  import ModulesAccessControl._

  trait AccessDef extends BasicAccessDef {

    /** Download */
    val P16 = Access.Pos(16)

    def values = Seq(P01, P02, P03, P06, P16)
  }

  object AccessDef extends AccessDef
}