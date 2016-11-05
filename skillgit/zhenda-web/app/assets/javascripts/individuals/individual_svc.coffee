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

views.individuals.individual_svc = angular.module 'individuals.individual_svc', [
  'api.helper'
  'ui.parts'
  'api_internal.user'
  'api_internal.individual'
  'api_internal.resident_id_record'
]

.factory 'IndividualSvc', [
  'User'
  'Individual'
  'ResidentIDRecord'
  'Alert'
  (User, Individual, ResidentIDRecord, Alert) ->
    service = {}
    service.individual_id = ''
    service.dictionary    = {}
    service.user =
      email     : ''
      user_name : ''
    service.individual =
      id_card_number : ''
      last_name      : ''
      first_name     : ''
      phone          : ''
      created        : false
    service.id_record = {}

    service.load = ->
      service.individual.created = true
      loadUser()
        .then loadIndividual
        .then (record_id) ->
          loadResidentIDRecord(record_id)
        .catch service.logProblems

    loadUser = ->
      User.get(
        id : service.individual_id
      ).$promise.then (user) ->
        service.user.id        = user.id
        service.user.email     = user.email
        service.user.user_name = user.user_name
        user.id

    loadIndividual = ->
      Individual.get(
        id : service.individual_id
      ).$promise.then (individual) ->
        service.individual.last_name  = individual.personal_name.last
        service.individual.first_name = individual.personal_name.first
        service.individual.phone      = individual.phones.default
        [record_id] = individual.resident_id_record_ids
        record_id

    loadResidentIDRecord = (record_id) ->
      if record_id?
        ResidentIDRecord.get(
          id : record_id
        ).$promise.then (record) ->
          service.individual.id_card_number = record.id_card_number
          service.id_record                 = record
          service.id_record.verified        = true

    service.logProblems = (fault) ->
      Alert.danger fault.data.message

    service.individualJson = ->
      individual =
        last_name  : service.individual.last_name
        first_name : service.individual.first_name
        email      : service.user.email
        phone      : service.individual.phone

    service.verify = ->
      Individual.verify(
        service.user.id, service.individual.id_card_number
      ).then(
        (resp) -> loadResidentIDRecord(resp.data.id)
        (error) -> Alert.danger error.data.message
      )

    service
]

angular.module('app').requires.push 'individuals.individual_svc'