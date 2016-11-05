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

views.customers._education = angular.module 'customers._education', [
  'ui.parts'
  'customers.contract'
]

.config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state(
      parent: 'education'
      name : 'highest_education'
      url: '/highest_education'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('highest_education').url
    )
    .state(
      parent: 'education'
      name : 'other_education'
      url: '/other_education'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('other_education').url
    )
]

.controller 'EducationCtrl', [
  '$scope'
  'ContractSvc'
  '$state'
  ($scope, ContractSvc, $state) ->
    $scope.ContractSvc = ContractSvc
    $scope.selected_bar = "highest_education"
    $state.go("highest_education")

    $scope.educationRouter = (key) ->
      $scope.selected_bar = key
      $state.go(key)

    return
]

angular.module('app').requires.push 'customers._education'