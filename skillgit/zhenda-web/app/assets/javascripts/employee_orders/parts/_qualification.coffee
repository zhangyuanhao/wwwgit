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

views.employee_orders._qualification = angular.module 'employee_orders._qualification', [
  'ui.parts'
  'ui.bootstrap'
  'api.helper'
  'employee_orders.index'
]

.controller 'QualificationCtrl', [
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

    EmployeeOrdersSvc.task_type   = 'Qualification'
    EmployeeOrdersSvc.role        = 1
    EmployeeOrdersSvc.search_date = new Date
    EmployeeOrdersSvc.loadCounts()

    if _.contains EmployeeOrdersSvc.filters, EmployeeOrdersSvc.filter
       $state.go(EmployeeOrdersSvc.task_type.toLowerCase() + '_' + EmployeeOrdersSvc.filter)
    else if EmployeeOrdersSvc.filter
      $state.go(EmployeeOrdersSvc.task_type.toLowerCase() + '_' + EmployeeOrdersSvc.filters[0])

    return
]

.controller 'QualificationCustomerComplainedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'customer_complained'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationAwaitingSubmissionCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'awaiting_submission'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationCandidateSubmittedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'candidate_submitted'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationReviewRequestedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_requested'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationReviewRejectedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_rejected'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationReviewPartiallyPassedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_partially_passed'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationReviewBasicallyPassedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_basically_passed'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationReviewFinallyPassedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'review_finally_passed'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationUnassignedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'unassigned'
    EmployeeOrdersSvc.reload()
]

.controller 'QualificationListHistoryTasksCtrl', [
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
        parent: '1'
        name : 'qualification_customer_complained'
        url: '/customer_complained'
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('investigator_customer_complained').url
        controller: 'QualificationCustomerComplainedCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_awaiting_submission'
        url: "/awaiting_submission"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('qualification_awaiting_submission').url
        controller: 'QualificationAwaitingSubmissionCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_candidate_submitted'
        url: "/candidate_submitted"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('candidate_submitted').url
        controller: 'QualificationCandidateSubmittedCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_review_requested'
        url: "/review_requested"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('investigator_review_requested').url
        controller: 'QualificationReviewRequestedCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_review_rejected'
        url: "/review_rejected"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('candidate_submitted').url
        controller: 'QualificationReviewRejectedCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_review_partially_passed'
        url: "/review_partially_passed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('candidate_submitted').url
        controller: 'QualificationReviewPartiallyPassedCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_review_basically_passed'
        url: "/review_basically_passed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('candidate_submitted').url
        controller: 'QualificationReviewBasicallyPassedCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_review_finally_passed'
        url: "/review_finally_passed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('review_finally_passed').url
        controller: 'QualificationReviewFinallyPassedCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_unassigned'
        url: "/unassigned"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('unassigned').url
        controller: 'QualificationUnassignedCtrl'
        )
      .state(
        parent: '1'
        name : 'qualification_list_history_tasks'
        url: "/list_history_tasks"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('list_history_tasks').url
        controller: 'QualificationListHistoryTasksCtrl'
        )
]

angular.module('app').requires.push 'employee_orders._qualification'