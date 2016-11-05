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
this.views.institutions ?= {}

views.institutions.edit = angular.module 'institutions.edit', [
  'ui.bootstrap'
  'ui.parts'
  'ui.common'
  'ui.address'
  'api.helper'
  'api_internal.institution'
]

.factory 'InstitutionSingleton', [
  'Institution'
  'Alert'
  '$filter'
  (Institution, Alert, $filter) ->
    service                  = {}
    service.value            = {}

    service.load = (id) ->
      if (not id)
        Institution.nnew().then (resp) ->
          service.value   = resp.data
        service.mode = 'new'
      else
        Institution.get id : id, (data) ->
          service.value = data
        service.mode  = 'edit'

    service.save = () ->
      if (service.mode isnt 'edit')
        Institution.create(
          service.value
          -> Alert.success service.dictionary['msg.created']
          (resp) -> Alert.danger resp.data.message
        )
      else
        service.value.$save(
          -> Alert.success service.dictionary['msg.saved']
          (resp) -> Alert.danger resp.data.message
        )

    return service
]

.controller 'InstitutionEditCtrl', [
  '$scope'
  'InstitutionSingleton'
  'Institution'
  ($scope, InstitutionSingleton, Institution) ->
    $scope.Singleton = InstitutionSingleton
    $scope.date_of_creation =
      date_options :
        datepickerMode : 'month'
        minMode        : 'month'
        maxDate        : new Date()
      opened : false
      open   : -> this.opened = true

    return
]

angular.module('app').requires.push 'institutions.edit'