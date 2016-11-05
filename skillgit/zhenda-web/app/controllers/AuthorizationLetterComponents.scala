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

import java.util.Locale

import akka.stream.scaladsl.Source
import akka.util._
import helpers.ExtLang._
import helpers._
import models.business.infogathering.{AuthorizationGathering => AuthG, _}
import org.joda.time._
import play.api.mvc._
import protocols._
import services._

import scala.concurrent._

/**
 * @author zepeng.li@factchina.com
 */
trait AuthorizationLetterComponents {
  self: BasicPlayComponents
    with DefaultPlayExecutor
    with Controller =>

  def fopService: FOPService

  /**
   * 根据信息收集表生成可下载的PDF版授权书
   */
  def generatePDFFrom(
    form: InfoGatheringForm,
    inline: Option[Boolean],
    onNotFound: => Result = NotFound
  ): Future[Result] = {
    generateAuthorizationPDF(AuthorizationSection.findIn(form), inline, onNotFound)
  }

  /**
   * 根据信息收集表中的授权部分生成可下载的PDF版授权书
   */
  def generateAuthorizationPDF(
    authOpt: Option[AuthorizationSection],
    inline: Option[Boolean],
    onNotFound: => Result = NotFound
  ): Future[Result] = {
    authOpt match {

      case Some(auth) if AuthG.Handwritten.existsIn(auth) =>
        generatePDF(AuthG.Handwritten.findIn(auth).get.provide.self).map { pdf =>
          HttpDownloadResult.send(pdf, inline = inline.contains(true))
        }

      case _ => Future.successful(onNotFound)
    }
  }

  /**
   * 生成可下载的PDF版授权书
   */
  def generatePDF(letter: Authorization.Handwritten) = {
    implicit val messages = messagesApi.preferred(Seq(Locale.CHINESE: Lang))
    import views.fo.pdf.authorization_letters
    for {
      bytes <- fopService.toPDF(
        userAgent = FOPService.UserAgent(
          title = Some(authorization_letters.metadata.title(letter)),
          subject = Some(authorization_letters.metadata.subject(letter)),
          author = configuration.getString("pdf.author"),
          producer = configuration.getString("pdf.producer"),
          creator = configuration.getString("pdf.creator"),
          creation_date = Some(DateTime.now),
          keywords = authorization_letters.metadata.keywords(letter)
        ),
        document = authorization_letters.handwritten(letter)
      )
    } yield new HttpDownloadable {
      def size = bytes.length
      def name = authorization_letters.metadata.filename(letter)
      def whole = Source.single(ByteString.fromArray(bytes))
    }
  }
}
