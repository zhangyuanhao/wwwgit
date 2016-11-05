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

views.employee_orders.history = angular.module 'employee_orders.history', [
  'ui.parts'
  'ui.bootstrap'
  'api_internal.employee_orders'
  'api_internal.task'
  'api_internal.order'
  'orders.order_svc'
  'api.helper'
]

views.employee_orders.history.factory 'HistorySvc', [
  'EmployeeOrder'
  'Task'
  'Order'
  'Alert'
  'OrderSvc'
  '$filter'
  (EmployeeOrder, Task, Order, Alert, OrderSvc, $filter) ->
    service                  = {}
    service.id               = ''
    service.task_type        = ''
    service.order            = {}
    service.order_events     = {}
    service.tasks_events     = {}
    service.dictionary       = {}
    service.dictionary.order = {}
    service.dictionary.task  = {}

    service.load = ->
      loadOrder()
        .then loadOrderEvents
        .then loadTasksEvents
        .catch logProblems

    loadOrder = ->
      EmployeeOrder.get(
        id : service.id
      ).$promise.then (order) =>
        service.order = order
        OrderSvc.loadServiceOptionsSet(order.options_set)

    loadOrderEvents = ->
      EmployeeOrder.tracks(
        id : service.id
      ).$promise.then (events) ->
        service.order_events = events
        _.map events, (data) =>
          p = data.principal
          data.full_name = $filter('personalName')(p.info?.personal_name, service.language)

    loadTasksEvents = ->
      if service.order.tasks.Qualification
        Task.events(
          service.order.tasks.Qualification
        ).then (resp) ->
          service.tasks_events.qualification = resp.data
      if service.order.tasks.Employment
        Task.events(
          service.order.tasks.Employment
        ).then (resp) ->
          service.tasks_events.employment = resp.data

    logProblems = (fault) ->
      if fault.data
        Alert.danger fault?.data?.message

    service
]

.controller 'HistoryCtrl', [
  '$scope'
  'HistorySvc'
  'OrderSvc'
  ($scope, HistorySvc, OrderSvc) ->
    $scope.HistorySvc = HistorySvc
    $scope.OrderSvc   = OrderSvc
    $scope.read_only  = 'true'

    HistorySvc.load()
    return
]

angular.module('app').requires.push 'employee_orders.history'