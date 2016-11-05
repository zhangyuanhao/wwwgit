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

views.customers.edit = angular.module 'customers.edit', [
  'ui.parts'
  'api_internal.business_entity'
  'api_internal.customer'
]

.controller 'EditCtrl', [
  '$scope'
  'Alert'
  'BusinessEntity'
  'Customer'
  'CustomerSvc'
  ($scope, Alert, BusinessEntity, Customer, CustomerSvc) ->
    $scope.CustomerSvc = CustomerSvc

    $scope.load = ->
      Customer.get(
        id : CustomerSvc.customer_id
        (customer) ->
          CustomerSvc.customer = customer
      )

    $scope.save = ->
      CustomerSvc.customer.$save(
        -> Alert.success CustomerSvc.dictionary['msg.saved']
        (res) -> Alert.danger res.data.message
      )

    $scope.load()
    return
]

angular.module('app').requires.push 'customers.edit'