#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

#
# UI Notification.
#
angular.module 'ui.notification', [
  'ui.parts'
  'ws.helper'
  'ngAnimate'
]

.controller 'NotificationCtrl', [
  '$scope'
  'Alert'
  'UserWebSocket'
  ($scope, Alert, UserWebSocket) ->
    $scope.Alert = Alert

    UserWebSocket.register
      protocol  : 'notification'
      onmessage : (notify) ->
        notify.type ?= 'info'
        notify.msg ?= notify.content
        $scope.Alert.push notify
        $scope.$apply()

    return
]