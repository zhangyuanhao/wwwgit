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

views.customers._basic = angular.module 'customers._basic', [
  'ui.parts'
  'customers.contract'
]

.config ['$stateProvider', ($stateProvider) ->
  $stateProvider
    .state(
      parent: 'basic'
      name : 'basic_setting'
      url: '/basic_setting'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('basic_setting').url
    )
    .state(
      parent: 'basic'
      name : 'purchased_services'
      url: '/purchased_services'
      templateUrl : jsRoutes.controllers.CustomersCtrl.contractParts('purchased_services').url
    )
]

.controller 'BasicCtrl', [
  '$scope'
  'ContractSvc'
  '$state'
  ($scope, ContractSvc, $state) ->
    $scope.ContractSvc = ContractSvc
    $scope.selected_bar = "basic_setting"
    $state.go("basic_setting")

    $scope.basicRouter = (key) ->
      $scope.selected_bar = key
      $state.go(key)

    $scope.purchasedServicesPackage = (key) ->
      purchased = ContractSvc.contract.content.purchased_services
      switch key
        when 'education_details' then purchased.degree            = purchased[key]
        when 'degree' then purchased.education_details            = purchased[key]
        when 'employment_details' then purchased.work_performance = purchased[key]
        when 'work_performance' then purchased.employment_details = purchased[key]
        when 'identity' then servicesCancel(purchased)

    servicesCancel = (p_ss) ->
      if p_ss.identity is false
        p_ss.criminal_records              = false
        p_ss.illegal_organization_records  = false
        p_ss.court_records                 = false
        p_ss.conflict_of_business_interest = false
        p_ss.financial_irregularities      = false

    return
]

angular.module('app').requires.push 'customers._basic'