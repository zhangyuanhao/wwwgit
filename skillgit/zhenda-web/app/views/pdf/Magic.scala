/*
 * Copyright (c) Factchina Inc, 2015-2016
 *
 * This unpublished material is proprietary to Factchina Inc.
 * All rights reserved. The methods and techniques described herein
 * are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part,
 * is forbidden except by express written permission of Factchina Inc.
 */
 package views.fo

import models.misc._
import play.api._
import play.twirl.api._

import scala.language.implicitConversions

/**
 * @author zepeng.li@factchina.com
 */
object Magic {

  /**
   * Generates a set of valid XML attributes.
   *
   * For example:
   * {{{
   * toXmlArgs(Map("id" -> "item", "style" -> "color:red"))
   * }}}
   */
  def toXmlArgs(args: Map[String, Any]) = Xml(
    args.map {
      case (key, None) => key
      case (key, v)    => key + "=\"" + XmlFormat.escape(v.toString).body + "\""
    }.mkString(" ")
  )

  /**
   * Read a image file then generates the data uri for it
   *
   * @param path the file path
   */
  def imageToDataURI(path: String)(implicit env: Environment) = {
    Option(env.classLoader.getResourceAsStream(path)).map { is =>
      try {
        DataURI.from(path, Stream.continually(is.read).takeWhile(_ != -1).map(_.toByte).toArray)
      } finally {
        is.close()
      }
    }.getOrElse(DataURI())
  }

  implicit def stringToXml(string: String): Xml = XmlFormat.escape(string)
}