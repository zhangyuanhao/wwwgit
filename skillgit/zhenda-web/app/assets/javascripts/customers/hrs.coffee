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

views.customers.hrs = angular.module('customers.hrs', [
  'ui.bootstrap'
  'ui.parts'
  'api.helper'
  'api_internal.customer'
  'api_internal.user'
])

.factory 'HRList', [
  'Customer'
  'Alert'
  (Customer, Alert) ->
    service        = {}
    service.values = []

    service.load = (customer_id) ->
      service.customer_id = customer_id
      service.values      = Customer.hrs id : customer_id

    service.create = (data) ->
      Customer.addHR
        id : service.customer_id,
        data,
        (value) ->
          if _.findIndex(service.values, id:value.id) is -1
            service.values.unshift value
        (resp) ->
          Alert.danger resp.data.message

    service.remove = (data) ->
      Customer.delHR
       id  : service.customer_id,
       rid : data.id,
        ->
          idx = service.values.indexOf(data)
          service.values.splice idx, 1

    service
]

.controller 'HRListCtrl', [
  '$scope'
  'HRList'
  'ModalDialog'
  ($scope, HRList, ModalDialog) ->
    $scope.List             = HRList
    ModalDialog.templateUrl = 'confirm_delete.html'

    $scope.confirm = (usr) ->
      ModalDialog.open().result.then(
        -> HRList.remove usr
        ->
      )
    return
]

.controller 'HRCtrl', [
  '$scope'
  '$http'
  'HRList'
  'User'
  ($scope, $http, HRList, User) ->
    $scope.List = HRList

    $scope.getUsers = (val) -> User.query(q : "email:#{val}*").$promise

    return
]

angular.module('app').requires.push 'customers.hrs'