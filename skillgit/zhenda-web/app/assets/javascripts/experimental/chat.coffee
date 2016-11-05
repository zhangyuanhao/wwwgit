#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

this.views ?= {}
this.views.experimental ?= {}

views.experimental.chat = angular.module 'experimental.chat', [
  'ws.helper'
  'ui.parts'
]

views.experimental.chat

.controller 'ChatCtrl', [
  '$scope'
  'UserWebSocket'
  ($scope, UserWebSocket) ->
    $scope.history = []
    $scope.message =
      to       : ""
      text     : ""
      code     : 0
      protocol : "chat"

    $scope.send = (msg) ->
      UserWebSocket.send msg
      $scope.history.push angular.copy(msg)

    UserWebSocket.register
      protocol  : 'chat'
      onmessage : (msg) ->
        $scope.history.push msg
        $scope.$apply()

    return
]

angular.module('app').requires.push 'experimental.chat'