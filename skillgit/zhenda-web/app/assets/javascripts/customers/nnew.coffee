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

views.customers.nnew = angular.module 'customers.nnew', [
  'ui.parts'
  'api_internal.business_entity'
  'api_internal.customer'
]

.controller 'NewCtrl', [
  '$scope'
  'Alert'
  'BusinessEntity'
  'Customer'
  'CustomerSvc'
  ($scope, Alert, BusinessEntity, Customer, CustomerSvc) ->
    $scope.CustomerSvc = CustomerSvc

    $scope.getBusinessEntities = (val) ->
      BusinessEntity.query(q : "name:#{val}").$promise

    $scope.create = ->
      be_id = CustomerSvc.business_entity.id
      Customer.get(
        id : be_id
        (customer) ->
          Alert.danger CustomerSvc.dictionary['msg.exist']
        ->
          createCustomer be_id
      )

    createCustomer = (be_id)->
      Customer.nnew().then (resp) ->
        customer = resp.data
        customer.id    = be_id
        customer.alias = CustomerSvc.customer.alias
        customer.phone = CustomerSvc.customer.phone
        customer.name = CustomerSvc.business_entity.name
        Customer.create(
          customer
          -> Alert.success CustomerSvc.dictionary['msg.created']
          (res) -> Alert.danger res.data.message
        )

    return
]

angular.module('app').requires.push 'customers.nnew'