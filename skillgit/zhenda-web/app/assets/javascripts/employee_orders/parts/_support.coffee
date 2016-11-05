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

views.employee_orders._support = angular.module 'employee_orders._support', [
  'ui.parts'
  'ui.bootstrap'
  'api.helper'
  'employee_orders.index'
]

.controller 'SupportCtrl', [
  'EmployeeOrdersSvc'
  '$state'
  (EmployeeOrdersSvc, $state) ->

    EmployeeOrdersSvc.filters = [
      'customer_complained',
      'partially_assigned',
      'fully_assigned',
      'basically_completed',
      'finally_completed',
      'unassigned',
      'customer_order_index'
    ]

    EmployeeOrdersSvc.task_type   = 'Support'
    EmployeeOrdersSvc.role        = 0
    EmployeeOrdersSvc.loadCounts()

    if _.contains EmployeeOrdersSvc.filters, EmployeeOrdersSvc.filter
       $state.go(EmployeeOrdersSvc.task_type.toLowerCase() + '_' + EmployeeOrdersSvc.filter)
    else if EmployeeOrdersSvc.filter
      $state.go(EmployeeOrdersSvc.task_type.toLowerCase() + '_' + EmployeeOrdersSvc.filters[0])

    return
]

.controller 'SupportCustomerComplainedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'customer_complained'
    EmployeeOrdersSvc.reload()
]

.controller 'PartiallyAssignedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'partially_assigned'
    EmployeeOrdersSvc.reload()
]

.controller 'FullyAssignedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'fully_assigned'
    EmployeeOrdersSvc.reload()
]

.controller 'SupportBasicallyCompletedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'basically_completed'
    EmployeeOrdersSvc.reload()
]

.controller 'SupportFinallyCompletedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'finally_completed'
    EmployeeOrdersSvc.reload()
]

.controller 'SupportUnassignedCtrl', [
  'EmployeeOrdersSvc'
  (EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter = 'unassigned'
    EmployeeOrdersSvc.reload()
]

.controller 'SupportCustomerOrderIndexCtrl', [
  '$scope'
  'EmployeeOrdersSvc'
  ($scope, EmployeeOrdersSvc) ->
    EmployeeOrdersSvc.filter       = 'customer_order_index'
    EmployeeOrdersSvc.links.prev   = null
    EmployeeOrdersSvc.links.next   = null
    EmployeeOrdersSvc.search_date  = new Date
    EmployeeOrdersSvc.action       = 'Place'
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

    EmployeeOrdersSvc.loadFollowing()
    .then (data) ->
      EmployeeOrdersSvc.employee.following = data
      # 初始化客户ID
      EmployeeOrdersSvc.customer_id        = _.first(_.keys(data))
      EmployeeOrdersSvc.reload()
]

.config [
  '$stateProvider'
  ($stateProvider) ->

    $stateProvider
      .state(
        parent: '0'
        name : 'support_customer_complained'
        url: '/customer_complained'
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('support_customer_complained').url
        controller: 'SupportCustomerComplainedCtrl'
        )
      .state(
        parent: '0'
        name : 'support_partially_assigned'
        url: "/partially_assigned"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('partially_assigned').url
        controller: 'PartiallyAssignedCtrl'
        )
      .state(
        parent: '0'
        name : 'support_fully_assigned'
        url: "/fully_assigned"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('fully_assigned').url
        controller: 'FullyAssignedCtrl'
        )
      .state(
        parent: '0'
        name : 'support_basically_completed'
        url: "/basically_completed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('support_basically_completed').url
        controller: 'SupportBasicallyCompletedCtrl'
        )
      .state(
        parent: '0'
        name : 'support_finally_completed'
        url: "/finally_completed"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('support_finally_completed').url
        controller: 'SupportFinallyCompletedCtrl'
        )
      .state(
        parent: '0'
        name : 'support_unassigned'
        url: "/unassigned"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('unassigned').url
        controller: 'SupportUnassignedCtrl'
        )
      .state(
        parent: '0'
        name : 'support_customer_order_index'
        url: "/customer_order_index"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('customer_order_index').url
        controller: 'SupportCustomerOrderIndexCtrl'
        )
]

angular.module('app').requires.push 'employee_orders._support'