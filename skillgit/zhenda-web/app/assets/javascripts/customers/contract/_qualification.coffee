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

views.customers._qualification = angular.module 'customers._qualification', [
  'ui.parts'
  'customers.contract'
]

.config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state(
      parent: 'qualification'
      name : 'identity'
      url: '/identity'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('identity').url
    )
    .state(
      parent: 'qualification'
      name : 'professional_license'
      url: '/professional_license'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('professional_license').url
    )
    .state(
      parent: 'qualification'
      name : 'criminal_record'
      url: '/criminal_record'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('criminal_record').url
    )
    .state(
      parent: 'qualification'
      name : 'illegal_organization_record'
      url: '/illegal_organization_record'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('illegal_organization_record').url
    )
    .state(
      parent: 'qualification'
      name : 'court_record'
      url: '/court_record'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('court_record').url
    )
    .state(
      parent: 'qualification'
      name : 'financial_irregularity'
      url: '/financial_irregularity'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('financial_irregularity').url
    )
    .state(
      parent: 'qualification'
      name : 'conflict_of_business_interest'
      url: '/conflict_of_business_interest'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('conflict_of_business_interest').url
    )
]

.controller 'QualificationCtrl', [
  '$scope'
  'ContractSvc'
  '$state'
  ($scope, ContractSvc, $state) ->
    $scope.ContractSvc = ContractSvc
    $scope.selected_bar = "identity"
    $state.go("identity")

    $scope.qualificationRouter = (key) ->
      $scope.selected_bar = key
      $state.go(key)

    return
]

angular.module('app').requires.push 'customers._qualification'