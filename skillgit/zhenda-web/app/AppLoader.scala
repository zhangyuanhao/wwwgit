/*
 * Copyright (c) Factchina Inc, 2015-2016
 *
 * This unpublished material is proprietary to Factchina Inc.
 * All rights reserved. The methods and techniques described herein
 * are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part,
 * is forbidden except by express written permission of Factchina Inc.
 */
import play.api.ApplicationLoader.Context

/**
 * @author zepeng.li@factchina.com
 */
class AppLoader
  extends play.api.ApplicationLoader {

  def load(context: Context) = {
    new Components(context).application
  }
}