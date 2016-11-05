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
this.views.customers ?= {}

views.customers.preferences = angular.module 'customers.preferences', [
  'orders.order_svc'
]

.controller 'PreferencesCtrl', [
  '$scope'
  'OrderSvc'
  ($scope, OrderSvc) ->
    $scope.OrderSvc = OrderSvc

    OrderSvc.loadPreferredKeys()
    return
]

angular.module('app').requires.push 'customers.preferences'