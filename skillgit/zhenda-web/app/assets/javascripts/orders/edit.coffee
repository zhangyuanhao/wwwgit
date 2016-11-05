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
this.views.orders ?= {}

views.orders.edit = angular.module 'orders.edit', [
  'ui.parts'
  'api.helper'
  'api_internal.order'
  'orders.order_svc'
]

.controller 'OrderCtrl', [
  '$scope'
  'Alert'
  'ClientError'
  'Order'
  'OrderSvc'
  ($scope, Alert, ClientError, Order, OrderSvc) ->
    $scope.OrderSvc = OrderSvc

    $scope.save = ->
      checkResult = OrderSvc.orderJsonCheck()
      if checkResult is "OK"
        order = OrderSvc.prepareOrderJson()
        order.id = OrderSvc.order_id
        new Order(order).$save(
          -> Alert.success OrderSvc.dictionary['msg.saved']
          (resp) -> Alert.danger ClientError.messages(resp)
        )
      else
        Alert.danger OrderSvc.dictionary[checkResult]

    OrderSvc.loadOrder()
    OrderSvc.loadPreferredKeys()
    return
]

angular.module('app').requires.push 'orders.edit'