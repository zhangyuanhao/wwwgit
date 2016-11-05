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
this.views.individuals ?= {}

views.individuals.edit = angular.module 'individuals.edit', [
  'api.helper'
  'ui.parts'
  'api_internal.individual'
  'individuals.individual_svc'
]

.controller 'EditCtrl', [
  '$scope'
  'Alert'
  'Individual'
  'IndividualSvc'
  ($scope, Alert, Individual, IndividualSvc) ->
    $scope.Service = IndividualSvc
    IndividualSvc.load()

    $scope.save = ->
      individual    = IndividualSvc.individualJson()
      individual.id = IndividualSvc.user.id
      new Individual(individual).$save(
        (resp)  -> Alert.success IndividualSvc.dictionary['msg.saved']
        (error) -> Alert.danger error.data.message
      )

    return
]

angular.module('app').requires.push 'individuals.edit'