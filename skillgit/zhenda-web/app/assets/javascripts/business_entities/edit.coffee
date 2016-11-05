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

views.business_entities.edit = angular.module 'businessEntities.edit', [
  'ui.parts'
  'ui.address'
  'api_internal.business_entity'
  'businessEntities.be_svc'
]

.controller 'EditCtrl', [
  '$scope'
  'Alert'
  'BESvc'
  'BusinessEntity'
  ($scope, Alert, BESvc, BusinessEntity) ->
    $scope.BESvc = BESvc

    $scope.load = ->
      BusinessEntity.get(
       id : BESvc.id
       (be) ->
          BESvc.value = be
      )

    $scope.save = ->
      BESvc.value.$save(
        -> Alert.success BESvc.dictionary['msg.saved']
        (resp) -> Alert.danger resp.data.message
      )

    $scope.load()
    return
]

angular.module('app').requires.push 'businessEntities.edit'