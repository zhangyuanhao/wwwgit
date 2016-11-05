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

views.employee_orders._employment = angular.module 'employee_orders._employment', [
  'ui.parts'
  'ui.bootstrap'
  'api.helper'
  'employee_orders.index'
]

.controller 'EmploymentCtrl', [
  'EmployeeOrdersSvc'
  '$state'
  (EmployeeOrdersSvc, $state) ->

    EmployeeOrdersSvc.filters = [
      'customer_complained',
      'awaiting_submission',
      'candidate_submitted',
      'review_requested',
      'review_rejected',
      'review_partially_passed',
      'review_basically_passed',
      'review_finally_passed',
      'unassigned',
      'list_history_tasks'
    ]

    EmployeeOrdersSvc.task_type   = 'Employment'
    EmployeeOrdersSvc.role        = 2
    EmployeeOrdersSvc.search_date = new Date
    EmployeeOrdersSvc.loadCounts()

    if _.contains EmployeeOrdersSvc.filters, EmployeeOrdersSvc.filter
       $state.go(EmployeeOrdersSvc.task_type.toLowerCase() + '_' + EmployeeOrdersSvc.filter)
    else if EmployeeOrdersSvc.filter
      $state.go(EmployeeOrdersSvc.task_type.toLowerCase() + '_' + EmployeeOrdersSvc.filters[0])

    return
]

.controller 'EmploymentCustomerComplainedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'customer_complained'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentAwaitingSubmissionCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'awaiting_submission'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentCandidateSubmittedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'candidate_submitted'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentReviewRequestedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_requested'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentReviewRejectedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_rejected'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentReviewPartiallyPassedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_partially_passed'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentReviewBasicallyPassedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_basically_passed'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentReviewFinallyPassedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_finally_passed'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentUnassignedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'unassigned'
    EmployeeOrdersSvc.reload()
]

.controller 'EmploymentListHistoryTasksCtrl', [
  '$scope'
  'EmployeeOrdersSvc'
  ($scope, EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter       = 'list_history_tasks'
    EmployeeOrdersSvc.links.prev   = null
    EmployeeOrdersSvc.links.next   = null
    EmployeeOrdersSvc.search_date  = new Date
    EmployeeOrdersSvc.action       = 'ReviewRequest'
    EmployeeOrdersSvc.options.page = 1

    $scope.index = ->
      EmployeeOrdersSvc.options.page = 1
      EmployeeOrdersSvc.reload()

    # load前page数据，不发生页面跳转
    $scope.loadPrevPage = ->
      if EmployeeOrdersSvc.links.prev
        EmployeeOrdersSvc.options.page -= 1
        EmployeeOrdersSvc.reload()

    # load后page数据，不发生页面跳转
    $scope.loadNextPage = ->
      if EmployeeOrdersSvc.links.next
        EmployeeOrdersSvc.options.page += 1
        EmployeeOrdersSvc.reload()

    EmployeeOrdersSvc.reload()
]

.config [
  '$stateProvider'
  ($stateProvider) ->

    $stateProvider
      .state(
        parent: '2'
        name : 'employment_customer_complained'
        url: '/customer_complained'
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('investigator_customer_complained').url
        controller: 'EmploymentCustomerComplainedCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_awaiting_submission'
        url: "/awaiting_submission"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('employment_awaiting_submission').url
        controller: 'EmploymentAwaitingSubmissionCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_candidate_submitted'
        url: "/candidate_submitted"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('candidate_submitted').url
        controller: 'EmploymentCandidateSubmittedCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_review_requested'
        url: "/review_requested"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('investigator_review_requested').url
        controller: 'EmploymentReviewRequestedCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_review_rejected'
        url: "/review_rejected"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('candidate_submitted').url
        controller: 'EmploymentReviewRejectedCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_review_partially_passed'
        url: "/review_partially_passed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('candidate_submitted').url
        controller: 'EmploymentReviewPartiallyPassedCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_review_basically_passed'
        url: "/review_basically_passed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('candidate_submitted').url
        controller: 'EmploymentReviewBasicallyPassedCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_review_finally_passed'
        url: "/review_finally_passed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('review_finally_passed').url
        controller: 'EmploymentReviewFinallyPassedCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_unassigned'
        url: "/unassigned"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('unassigned').url
        controller: 'EmploymentUnassignedCtrl'
        )
      .state(
        parent: '2'
        name : 'employment_list_history_tasks'
        url: "/list_history_tasks"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('list_history_tasks').url
        controller: 'EmploymentListHistoryTasksCtrl'
        )
]

angular.module('app').requires.push 'employee_orders._employment'