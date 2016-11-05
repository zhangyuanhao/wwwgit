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
this.views.business_entities ?= {}

views.business_entities.nnew = angular.module 'businessEntities.nnew', [
  'ui.parts'
  'ui.address'
  'api_internal.business_entity'
  'businessEntities.be_svc'
]

.controller 'NewCtrl', [
  '$scope'
  'Alert'
  'BESvc'
  'BusinessEntity'
  ($scope, Alert, BESvc, BusinessEntity) ->
    $scope.BESvc = BESvc

    $scope.load = ->
      BusinessEntity.nnew().then (resp) ->
        BESvc.value = resp.data

    $scope.create = ->
      BusinessEntity.create(
        BESvc.value
        -> Alert.success BESvc.dictionary['msg.created']
        (resp) -> Alert.danger resp.data.message
      )

    $scope.load()
    return
]

angular.module('app').requires.push 'businessEntities.nnew'