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

views.customers._employment = angular.module 'customers._employment', [
  'ui.parts'
  'customers.contract'
]

.config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state(
      parent: 'employment'
      name : 'last_personnel_officer'
      url: '/last_personnel_officer'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('last_personnel_officer').url
    )
    .state(
      parent: 'employment'
      name : 'last_supervisor'
      url: '/last_supervisor'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('last_supervisor').url
    )
    .state(
      parent: 'employment'
      name : 'last_additional1'
      url: '/last_additional1'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('last_additional1').url
    )
    .state(
      parent: 'employment'
      name : 'last_additional2'
      url: '/last_additional2'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('last_additional2').url
    )
    .state(
      parent: 'employment'
      name : 'previous_personnel_officer'
      url: '/previous_personnel_officer'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('previous_personnel_officer').url
    )
    .state(
      parent: 'employment'
      name : 'previous_supervisor'
      url: '/previous_supervisor'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('previous_supervisor').url
    )
    .state(
      parent: 'employment'
      name : 'previous_additional1'
      url: '/previous_additional1'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('previous_additional1').url
    )
    .state(
      parent: 'employment'
      name : 'previous_additional2'
      url: '/previous_additional2'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('previous_additional2').url
    )
]

.controller 'EmploymentCtrl', [
  '$scope'
  'ContractSvc'
  '$state'
  ($scope, ContractSvc, $state) ->
    $scope.ContractSvc = ContractSvc
    $scope.selected_bar = "last_personnel_officer"
    $state.go("last_personnel_officer")

    $scope.employmentRouter = (key) ->
      $scope.selected_bar = key
      $state.go(key)

    return
]

angular.module('app').requires.push 'customers._employment'