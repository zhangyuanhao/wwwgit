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

views.individuals.nnew = angular.module 'individuals.nnew', [
  'api.helper'
  'ui.parts'
  'api_internal.user'
  'api_internal.individual'
  'individuals.individual_svc'
]

.controller 'NNewCtrl', [
  '$scope'
  'Alert'
  'User'
  'Individual'
  'IndividualSvc'
  ($scope, Alert, User, Individual, IndividualSvc) ->
    $scope.Service = IndividualSvc

    $scope.create = ->
      createUser()
        .then (uid)->
          createIndividual(uid)
        .catch (error)->
          IndividualSvc.logProblems(error)

    createUser = ->
      user =
        email     : IndividualSvc.user.email
        user_name : IndividualSvc.user.user_name
      User.save(
        user
      ).$promise.then (resp)->
        IndividualSvc.user.id = resp.id

    createIndividual = (uid)->
      individual    = IndividualSvc.individualJson()
      individual.id = uid
      Individual.create(
        individual
      ).$promise.then ->
        IndividualSvc.individual.created = true
        Alert.success IndividualSvc.dictionary['msg.created']

    return
]

angular.module('app').requires.push 'individuals.nnew'