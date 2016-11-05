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

import play.api.i18n.Messages
import play.api.libs.json._

object EnumToJson {

  /**
   * @author shu.zhang@factchina.com
   */
  object CurrencyCodesDef {

    /**
     * 画面显示用的货币编号
     *
     * @return 一个包含 currency_code -> message(currency_code) 序列的JsObject
     */
    def toJson(implicit messages: Messages) = Json.prettyPrint(
      JsObject(
        List("CNY", "HKD", "TWD", "USD", "JPY", "KRW", "GBP", "EUR").map { s =>
          s -> JsString(messages(s"Currency.$s"))
        }
      )
    )
  }

  object IdDocTypesDef {

    /**
     * 画面显示用的证件类型
     *
     * @return 一个包含 id_doc_type -> message(id_doc_type) 序列的JsObject
     */
    def toJson(implicit messages: Messages) = Json.prettyPrint(
      JsObject(
        List("cn.id_card_number", "cn.passport_number", "cn.eep_number").map { s =>
          s -> JsString(messages(s"IdDocType.$s"))
        }
      )
    )
  }

  object LangsDef {

    /**
     * 画面显示用的语言种类
     *
     * @return 一个包含 lang.code -> message(lang.code) 序列的JsObject
     */
    def toJson(implicit messages: Messages) = Json.prettyPrint(
      JsObject(
        List("en", "en-US", "zh", "ja").map { s =>
          s -> JsString(messages(s"lang.$s"))
        }
      )
    )
  }
}