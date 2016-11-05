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
this.views.orders ?= {}

views.orders.index = angular.module 'orders.index', [
  'ui.bootstrap'
  'ui.parts'
  'ui.router'
  'api_internal.order'
  'api_internal.customer'
  'api.helper'
]

views.orders.index.factory 'OrderListSvc', [
  '$filter'
  'Order'
  'LinkHeader'
  'Alert'
  'Customer'
  ($filter, Order, LinkHeader, Alert, Customer) ->
    service                    = {}
    service.links              = LinkHeader.links
    service.orders             = []
    service.counts             = {}
    service.options            = {}
    service.dictionary         = {}
    service.customer_id        = ''
    service.account_executives = []
    service.actions_def        = []
    service.start_date         = new Date
    service.end_date           = new Date
    service.start_date_picker  = {}
    service.end_date_picker    = {}

    newDatepicker = ->
      opened  : false
      open    : -> this.opened = true
      options :
        mode    : 'month'
        maxDate : new Date
        minMode : 'month'
        showWeeks : false

    # 根据检索条件创建querystring
    buildQueryString = (q) ->
      if q
        "((candidate_info.personal_name.full_name:#{q})OR(candidate_info.email:#{q}*)OR(candidate_info.phone:*#{q}*))"
      else
        "((candidate_info.personal_name.full_name:*)OR(candidate_info.email:*)OR(candidate_info.phone:*))"

    # all_orders的场合通过elasticsearch取得
    service.loadAllOrders = (keyword) ->
      service.orders = []
      opt            = service.options
      query_string   = buildQueryString(keyword ? '')
      Order
        .search
          page     : opt.page
          per_page : opt.pageSize
          q        : query_string
          sort     : opt.sort.join(',')
        .then (
          (resp) ->
            service.orders = resp.data
            LinkHeader.updateLinks opt.nextPage, opt.prevPage, resp.headers
          )

    # 检索某月到某月的所有订单
    service.searchOrders = ->
      service.orders = []
      opt            = service.options
      start_date     = $filter('date')(Date.parse(service.start_date), "yyyy-MM")
      end_date       = $filter('date')(Date.parse(service.end_date), "yyyy-MM")
      Order
        .index
          start    : start_date
          end      : end_date
          action   : service.action
          page     : opt.page
          per_page : opt.pageSize
        .then (
          (resp) ->
            service.orders = resp.data
            LinkHeader.updateLinks opt.nextPage, opt.prevPage, resp.headers
          )

    # 取得订单列表
    service.loadOrders = ->
      service.orders = []
      Order.query(
        filter : service.condition_status
        ).$promise.then (orders) =>
          service.orders = orders

    # 取得订单个数
    service.loadCounts = ->
      filters = [
                  'awaiting_submission',
                  'in_progress',
                  'basically_completed',
                  'customer_complained',
                  'finally_completed'
                ]
      Order.counts(filters).then (resp) =>
        service.counts = resp.data

    logProblems = (fault) ->
      if fault.data.message
        Alert.danger fault.data.message

    # 取得客服联系方式
    service.loadAccountExecutives = ->
      Customer.account_executives(
        id : service.customer_id
        (data) ->
          service.account_executives = data
      )

    service.initSearchDate = ->
      service.start_date_picker  = newDatepicker()
      service.end_date_picker    = newDatepicker()

    service
]

.controller 'OrderCtrl', [
  '$scope'
  'OrderListSvc'
  ($scope, OrderListSvc) ->
    $scope.OrderListSvc     = OrderListSvc
    $scope.dictionary       = OrderListSvc.dictionary
    $scope.jsRoutes         = jsRoutes
    $scope.isCollapsed      = false

    OrderListSvc.loadCounts()
    .then OrderListSvc.loadAccountExecutives

    return
]

.controller 'AllOrdersCtrl', [
  '$scope'
  'OrderListSvc'
  ($scope, OrderListSvc) ->
    OrderListSvc.condition_status = 'all_orders'
    OrderListSvc.links.prev       = null
    OrderListSvc.links.next       = null
    OrderListSvc.options.page     = 1
    $scope.keyword                = ''

    # load前page数据，不发生页面跳转
    $scope.loadPrevPage = ->
      if OrderListSvc.links.prev
        OrderListSvc.options.page -= 1
        OrderListSvc.loadAllOrders($scope.keyword)

    # load后page数据，不发生页面跳转
    $scope.loadNextPage = ->
      if OrderListSvc.links.next
        OrderListSvc.options.page += 1
        OrderListSvc.loadAllOrders($scope.keyword)

    $scope.$watch 'keyword', (nv) ->
      OrderListSvc.options.page = 1
      OrderListSvc.loadAllOrders nv
    return
]

.controller 'SearchOrdersCtrl', [
  '$scope'
  'OrderListSvc'
  ($scope, OrderListSvc) ->
    OrderListSvc.condition_status = 'search_orders'
    OrderListSvc.links.prev       = null
    OrderListSvc.links.next       = null
    OrderListSvc.options.page     = 1
    OrderListSvc.start_date       = new Date
    OrderListSvc.end_date         = new Date
    OrderListSvc.action           = 'Place'

    # load前page数据，不发生页面跳转
    $scope.loadPrevPage = ->
      if OrderListSvc.links.prev
        OrderListSvc.options.page -= 1
        OrderListSvc.searchOrders()

    # load后page数据，不发生页面跳转
    $scope.loadNextPage = ->
      if OrderListSvc.links.next
        OrderListSvc.options.page += 1
        OrderListSvc.searchOrders()

    $scope.index = ->
      OrderListSvc.options.page = 1
      OrderListSvc.searchOrders()

    OrderListSvc.searchOrders()

    return
]

.controller 'AwaitingSubmissionCtrl', [
  '$scope'
  'OrderListSvc'
  ($scope, OrderListSvc) ->
    OrderListSvc.condition_status = 'awaiting_submission'
    OrderListSvc.options.page     = 1

    OrderListSvc.loadOrders()

    return
]

.controller 'InProgressCtrl', [
  '$scope'
  'OrderListSvc'
  ($scope, OrderListSvc) ->
    OrderListSvc.condition_status = 'in_progress'
    OrderListSvc.options.page     = 1

    OrderListSvc.loadOrders()

    return
]

.controller 'CustomerComplainedCtrl', [
  '$scope'
  'OrderListSvc'
  ($scope, OrderListSvc) ->
    OrderListSvc.condition_status = 'customer_complained'
    OrderListSvc.options.page     = 1

    OrderListSvc.loadOrders()

    return
]

.controller 'BasicallyCompletedCtrl', [
  '$scope'
  'OrderListSvc'
  ($scope, OrderListSvc) ->
    OrderListSvc.condition_status = 'basically_completed'
    OrderListSvc.options.page     = 1

    OrderListSvc.loadOrders()

    return
]

.controller 'FinallyCompletedCtrl', [
  '$scope'
  'OrderListSvc'
  ($scope, OrderListSvc) ->
    OrderListSvc.condition_status = 'finally_completed'
    OrderListSvc.options.page     = 1

    OrderListSvc.loadOrders()

    return
]

.config [
  '$stateProvider'
  '$urlRouterProvider'
  ($stateProvider, $urlRouterProvider) ->

    $urlRouterProvider.otherwise('/all_orders')

    $stateProvider
      .state(
        name : 'all_orders'
        url: "/all_orders"
        templateUrl : jsRoutes.controllers.CustomerUserOrdersCtrl.parts('all_orders').url
        controller : 'AllOrdersCtrl'
        )
      .state(
        name : 'search_orders'
        url: "/search_orders"
        templateUrl : jsRoutes.controllers.CustomerUserOrdersCtrl.parts('search_orders').url
        controller : 'SearchOrdersCtrl'
        )
      .state(
        name : 'awaiting_submission'
        url: "/awaiting_submission"
        templateUrl : jsRoutes.controllers.CustomerUserOrdersCtrl.parts('awaiting_submission').url
        controller : 'AwaitingSubmissionCtrl'
        )
      .state(
        name : 'in_progress'
        url: "/in_progress"
        templateUrl : jsRoutes.controllers.CustomerUserOrdersCtrl.parts('in_progress').url
        controller : 'InProgressCtrl'
        )
      .state(
        name : 'customer_complained'
        url: "/customer_complained"
        templateUrl : jsRoutes.controllers.CustomerUserOrdersCtrl.parts('customer_complained').url
        controller : 'CustomerComplainedCtrl'
        )
      .state(
        name : 'basically_completed'
        url: "/basically_completed"
        templateUrl : jsRoutes.controllers.CustomerUserOrdersCtrl.parts('basically_completed').url
        controller : 'BasicallyCompletedCtrl'
        )
      .state(
        name : 'finally_completed'
        url: "/finally_completed"
        templateUrl : jsRoutes.controllers.CustomerUserOrdersCtrl.parts('finally_completed').url
        controller : 'FinallyCompletedCtrl'
        )
]

angular.module('app').requires.push 'orders.index'