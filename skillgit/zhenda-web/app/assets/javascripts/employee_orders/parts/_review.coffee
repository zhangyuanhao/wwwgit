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
this.views.employee_orders ?= {}

views.employee_orders._review = angular.module 'employee_orders._review', [
  'ui.parts'
  'ui.bootstrap'
  'api.helper'
  'employee_orders.index'
]

.controller 'ReviewCtrl', [
  'EmployeeOrdersSvc'
  '$state'
  (EmployeeOrdersSvc, $state) ->

    EmployeeOrdersSvc.filters = [
      'customer_complained',
      'awaiting_review_request',
      'review_requested',
      'basically_completed',
      'finally_completed',
      'unassigned'
    ]

    EmployeeOrdersSvc.task_type   = 'Review'
    EmployeeOrdersSvc.role        = 3
    EmployeeOrdersSvc.search_date = new Date
    EmployeeOrdersSvc.loadCounts()

    if _.contains EmployeeOrdersSvc.filters, EmployeeOrdersSvc.filter
       $state.go(EmployeeOrdersSvc.task_type.toLowerCase() + '_' + EmployeeOrdersSvc.filter)
    else if EmployeeOrdersSvc.filter
      $state.go(EmployeeOrdersSvc.task_type.toLowerCase() + '_' + EmployeeOrdersSvc.filters[0])

    return
]

.controller 'ReviewCustomerComplainedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'customer_complained'
    EmployeeOrdersSvc.reload()
]

.controller 'ReviewAwaitingReviewRequestCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'awaiting_review_request'
    EmployeeOrdersSvc.reload()
]

.controller 'ReviewReviewRequestedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_requested'
    EmployeeOrdersSvc.reload()
]

.controller 'ReviewBasicallyCompletedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'basically_completed'
    EmployeeOrdersSvc.reload()
]

.controller 'ReviewFinallyCompletedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'finally_completed'
    EmployeeOrdersSvc.reload()
]

.controller 'ReviewUnassignedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'unassigned'
    EmployeeOrdersSvc.reload()
]

.config [
  '$stateProvider'
  ($stateProvider) ->

    $stateProvider
      .state(
        parent: '3'
        name : 'review_customer_complained'
        url: "/customer_complained"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('review_customer_complained').url
        controller: 'ReviewCustomerComplainedCtrl'
        )
      .state(
        parent: '3'
        name : 'review_awaiting_review_request'
        url: "/awaiting_review_request"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('awaiting_review_request').url
        controller: 'ReviewAwaitingReviewRequestCtrl'
        )
      .state(
        parent: '3'
        name : 'review_review_requested'
        url: "/review_requested"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('review_review_requested').url
        controller: 'ReviewReviewRequestedCtrl'
        )
      .state(
        parent: '3'
        name : 'review_basically_completed'
        url: "/basically_completed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('review_basically_completed').url
        controller: 'ReviewBasicallyCompletedCtrl'
        )
      .state(
        parent: '3'
        name : 'review_finally_completed'
        url: "/finally_completed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('review_finally_completed').url
        controller: 'ReviewFinallyCompletedCtrl'
        )
      .state(
        parent: '3'
        name : 'review_unassigned'
        url: "/unassigned"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('review_unassigned').url
        controller: 'ReviewUnassignedCtrl'
        )
]

angular.module('app').requires.push 'employee_orders._review'