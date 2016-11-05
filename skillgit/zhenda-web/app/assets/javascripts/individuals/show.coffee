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

views.individuals.show = angular.module 'individuals.show', [
  'api_internal.individual',
  'api_internal.user',
  'api.helper',
  'ui.parts'
]

views.individuals.show

.factory 'IndividualSingleton', [
  'Individual'
  'User'
  'Alert'
  (Individual, User, Alert) ->
    service                   = {}
    service.value             = {}
    service.dictionary        = {}
    service.residentIdRecords = []
    service.user              = {}
    service.user.exists       = false

    service.load = (individual_id) ->
      loadIndividual individual_id
        .then loadResidentIdRecords
        .then loadUser
        .catch logProblems

    loadIndividual = (individual_id) ->
      Individual.get(
        id : individual_id
      ).$promise.then (individual) ->
        service.value = individual
        individual_id

    loadResidentIdRecords = (individual_id) ->
      Individual.residentIdRecords(
        id : individual_id
      ).$promise.then (records) ->
        service.residentIdRecords = records
        individual_id

    loadUser = (individual_id) ->
      User.get(
        id: individual_id
      ).$promise.then(
        (user) ->
          service.user = user
          service.user.exists = true
          individual_id
        (resp) ->
          service.user =
            uid   : individual_id
            email : ''
          service.user.exists = false
          individual_id
      )

    logProblems = (fault) ->
      console.log String(fault)

    service.create = (data) ->
      User.save(
        data
        ->
          service.user.exists = true
        (resp) ->
          Alert.danger resp.data.message
          service.user.exists = false
      )

    service
]

.controller 'ShowCtrl', [
  '$scope'
  'IndividualSingleton'
  ($scope, IndividualSingleton) ->
    $scope.Singleton = IndividualSingleton

    $scope.create = (data) -> IndividualSingleton.create data

    return
]

angular.module('app').requires.push 'individuals.show'