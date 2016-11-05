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
this.views.service_options ?= {}

views.service_options.preferred_set = angular.module 'service_options.preferred_set', [
  'ui.parts'
  'api_internal.order'
  'orders.order_svc'
]

.controller 'PreferenceCtrl', [
  '$scope'
  '$uibModal'
  'OrderSvc'
  ($scope, $uibModal, OrderSvc) ->
    $scope.OrderSvc = OrderSvc

    $scope.open = ->
      modalInstance = $uibModal.open(
        templateUrl : 'preferred_set.html'
        controller  : 'PreferredSetCtrl'
      )

    return
]

.controller 'PreferredSetCtrl', [
  '$scope'
  '$uibModalInstance'
  'Customer'
  'OrderSvc'
  ($scope, $uibModalInstance, Customer, OrderSvc) ->
    $scope.package_name = ''
    $scope.OrderSvc     = OrderSvc

    $scope.addPreferredServiceSet = ->
      Customer.addServiceSet
        id  : OrderSvc.customer_id
        rid : $scope.package_name,
        OrderSvc.prepareServiceSetJson(),
        ->
          OrderSvc.loadPreferredKeys()
          OrderSvc.package_name = $scope.package_name

    $scope.delPreferredServiceSet = (key) ->
      Customer.delServiceSet
        id  : OrderSvc.customer_id
        rid : key,
        -> OrderSvc.loadPreferredKeys()

    $scope.close = ->
      $uibModalInstance.dismiss('close')
]

angular.module('app').requires.push 'service_options.preferred_set'