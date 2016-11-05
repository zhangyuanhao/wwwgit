/*
 * Copyright (c) Factchina Inc, 2015-2016
 *
 * This unpublished material is proprietary to Factchina Inc.
 * All rights reserved. The methods and techniques described herein
 * are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part,
 * is forbidden except by express written permission of Factchina Inc.
 */
package views

import java.util.Locale

import helpers.ExtDateTimeFormat._
import models.business.pay._
import models.business.providers._
import models.business.services._
import models.business.services.definitions._
import models.fact._
import models.misc._
import org.joda.money.CurrencyUnit
import org.joda.time.LocalDate
import play.api.i18n._

/**
 * @author zepeng.li@factchina.com
 */
object ClassFormats {

  def display[T](obj: T)(implicit messages: Messages): String = obj match {
    case o: String                       => o
    case o: Boolean                      => o.toString
    case o: Address                      => o.format
    case o: Name                         => o.format
    case o: LocalDateInterval            => o.format
    case o: LocalDateIntervalOptionalEnd => o.format
    case o: PositionTitle                => o.format
    case o: Earnings                     => o.format
    case o: PersonalBasicInfo            => o.format
    case o: ModeOfStudy                  => ModeOfStudy.msg(o)
    case o: EducationLevel               => EducationLevel.msg(o)
    case o: HireType                     => HireType.msg(o)
    case o: Trilean                      => messages(s"trilean.${o.self}")
    case o: LocalDate                    => DateTimeFormat("date.format.long").print(o)
    case o: NonEmptyText                 => o.self
    case o: PersonalName.FullName        => o.self
    case o: CurrencyUnit                 => o.format
    case o: IdentityDocumentNumber       => o.format
    case o: Translated[_]                => o.format
    case o: TranslatedOrigin[_]          => o.format
    case o: Provide[_]                   => o.format
    case None                            => ""
    case Some(o)                         => display(o)
    case _                               => "TODO"
  }

  /**
   * 格式化显示 Option[ Provide[T] ]
   */
  implicit class OptionalProvideClassFormat[T](val provide: Option[Provide[T]]) extends AnyVal {

    def format(implicit messages: Messages): String = provide match {
      case Some(Provide(p)) => display(p)
      case None             => messages("not_provided")
    }
  }

  /**
   * 格式化显示 Provide[T]
   */
  implicit class ProvideClassFormat[T](val provide: Provide[T]) extends AnyVal {

    def format(implicit messages: Messages): String = display(provide.self)
  }

  /**
   * 格式化显示 Option[T]
   */
  implicit class OptionalClassFormat[T](val option: Option[T]) extends AnyVal {

    def format(implicit messages: Messages): String = display(option)

    def formatOrElse(default: String)(implicit messages: Messages): String = {
      option.map(display(_)).getOrElse(messages(default))
    }
  }

  /**
   * 为Translated中的各种类型数据进行String的format
   */
  implicit class TranslatedClassFormat[T](val translated: Translated[T]) {

    def format(implicit messages: Messages): String = display(translated.self.get(messages.lang))
  }

  /**
   * 为TranslatedOrigin中的各种类型数据进行String的format
   */
  implicit class TranslatedOriginClassFormat[T](val translatedOrigin: TranslatedOrigin[T]) {

    def format(implicit messages: Messages): String =
      translatedOrigin.translated match {
        case None    => display(translatedOrigin.origin)
        case Some(t) =>
          val result = display(t)
          result match {
            case "" => display(translatedOrigin.origin)
            case _  => result
          }
      }
  }

  /**
   * 格式化显示 Name
   */
  implicit class NameFormat[T](val name: Name) {

    def format(implicit messages: Messages): String = name.self
  }

  /**
   * 格式化显示 LocalDate
   */
  implicit class LocalDateFormat[T](val localDate: LocalDate) {

    def format(implicit messages: Messages): String = display(localDate)
  }

  /**
   * 格式化显示 CurrencyUnit
   */
  implicit class CurrencyUnitFormat[T](val currency: CurrencyUnit) {

    def format(implicit messages: Messages): String = messages(s"Currency.${currency.getCurrencyCode}")
  }

  /**
   * 在授权书的PDF文档中,格式化显示IdentityDocumentNumber
   */
  implicit class IdentityDocumentNumberFormat[T](val id: IdentityDocumentNumber) {

    def format(implicit messages: Messages): String = id.number
  }

  /**
   * 根据country对Address进行格式化,返回用来显示的字符串
   */
  implicit class AddressClassFormat(val address: Address) extends AnyVal {

    def format(implicit messages: Messages): String = address match {
      case addr: Address001 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.province} ${addr.city} ${addr.street1} ${addr.street2}"""
      case addr: Address002 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.province} ${addr.district} ${addr.street1} ${addr.street2}"""
      case addr: Address003 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.city} ${addr.district} ${addr.street1} ${addr.street2}"""
      case addr: Address004 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.governorate} ${addr.district} ${addr.street1} ${addr.street2}"""
      case addr: Address005 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.city} ${addr.suburb} ${addr.street1} ${addr.street2}"""
      case addr: Address006 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.state} ${addr.suburb} ${addr.street1} ${addr.street2}"""
      case addr: Address007 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.state} ${addr.city} ${addr.street1} ${addr.street2}"""
      case addr: Address008 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.county} ${addr.city} ${addr.street1} ${addr.street2}"""
      case addr: Address009 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.city} ${addr.street1} ${addr.street2}"""
      case addr: Address010 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.state} ${addr.city} ${addr.street1} ${addr.street2}"""
      case addr: Address011 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.prefecture} ${addr.country_city} ${addr.further_divisions1} ${addr.further_divisions2}"""
      case addr: Address012 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.county} ${addr.township} ${addr.street1} ${addr.street2}"""
      case addr: Address013 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.region} ${addr.district} ${addr.street1} ${addr.street2}"""
      case addr: Address014 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.region} ${addr.city} ${addr.street1} ${addr.street2}"""
      case addr: Address100 =>
        s"""${messages(s"Country.${addr.country.code}")} ${addr.city} ${addr.street1} ${addr.street2}"""
      case _                => "TODO"
    }
  }

  /**
   * 将LocalDateInterval格式化为字符串
   */
  implicit class LocalDateInternalClassFormat(val interval: LocalDateInterval) extends AnyVal {

    def format(implicit messages: Messages): String = {
      val fmt = DateTimeFormat(messages("month.format.long"))
      messages("format.interval", fmt.print(interval.start), fmt.print(interval.end))
    }
  }

  /**
   * 将LocalDateIntervalOptionalEnd格式化为字符串
   */

  implicit class LocalDateIntervalOptionalEndClassFormat(val interval: LocalDateIntervalOptionalEnd) extends AnyVal {

    def format(implicit messages: Messages): String = {
      val fmt = DateTimeFormat(messages("month.format.long"))
      interval.end match {
        case Some(end) =>
          messages("format.interval", fmt.print(interval.start), fmt.print(end))
        case None      =>
          messages("format.interval", fmt.print(interval.start), messages("until_now"))
      }
    }
  }

  /**
   * 将PersonalBasicInfo转化为显示用的字符串
   */
  implicit class PersonalBasicInfoClassFormat(val basicInfo: PersonalBasicInfo) {

    def format(implicit messages: Messages): String =
      messages(s"IdDocType.${basicInfo.id_doc_nbr.basicName}") + " : " + basicInfo.id_doc_nbr.number
  }

  /**
   * 将Earnings转化为显示用的字符串
   */
  implicit class EarningClassFormat(val earnings: Earnings) {

    def format(implicit messages: Messages): String = {
      earnings
        .collectFirst { case s: Salary => s }
        .map { salary =>
          messages(
            "format.salary",
            messages(s"Salary.Period.${salary.period}"),
            salary.rate.getAmount.toString,
            messages(s"Currency.${salary.rate.getCurrencyUnit}")
          )
        }.getOrElse("")
    }
  }

  /**
   * 将PersonalName格式化为用来显示的字符串
   */
  implicit class PersonalNameFormat(val name: PersonalName) extends AnyVal {

    def format(implicit messages: Messages): String = messages.lang.language match {
      case l if l == Locale.CHINESE.getLanguage => s"${name.last}${name.first}"
      case l if l == Locale.ENGLISH.getLanguage => (name.first +: name.middle :+ name.last).mkString(" ")
      case _                                    => (name.first +: name.middle :+ name.last).mkString(" ")
    }

  }

  /**
   * 将PositionTitle格式化为用来显示的字符串
   */
  implicit class PositionTitleFormat(val position_title: PositionTitle) extends AnyVal {

    def format(implicit messages: Messages): String =
      s"${position_title.department.map(_.self).getOrElse("")} ${position_title.job_title.self}"
  }
}