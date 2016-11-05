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

views.employee_orders.index = angular.module 'employee_orders.index', [
  'ui.parts'
  'ui.bootstrap'
  'ui.router'
  'api_internal.employee'
  'api_internal.employee_orders'
  'api_internal.employee_customers'
  'api.helper'
]

views.employee_orders.index.factory 'EmployeeOrdersSvc', [
  '$filter'
  '$timeout'
  'Employee'
  'EmployeeOrder'
  'EmployeeCustomer'
  'LinkHeader'
  'Alert'
  ($filter, $timeout, Employee, EmployeeOrder, EmployeeCustomer, LinkHeader, Alert) ->
    service                    = {}
    service.links              = LinkHeader.links
    service.employee_id        = ''
    service.orders             = []
    service.options            = {}
    service.counts             = {}
    service.dictionary         = {}
    service.filters            = []
    service.filter             = ''
    service.role               = ''
    service.task_type          = ''
    service.roles_def          = []
    service.employee           = {}
    service.employee_roles     = {}
    service.mistakes           = []
    service.confirm_type       = ''
    service.actions_def        = []
    service.action             = ''
    service.customer_id        = ''
    service.search_date        = new Date
    service.date_picker        =
      opened  : false
      open    : -> this.opened = true
      options :
        mode    : 'month'
        maxDate : new Date
        minMode : 'month'
        showWeeks : false

    logProblems = (fault) ->
      if fault.data.message
        Alert.danger fault.data.message

    # load员工角色，员工可能具备多重角色
    service.loadEmployee = ->
      Employee.get(
        id : service.employee_id
      ).$promise.then (data) =>
        service.employee       = data
        # 设置员工角色选择列表
        employee_roles_def     = (service.roles_def[i] for i in data.roles)
        service.employee_roles = _.object(data.roles, employee_roles_def)

    service.loadFollowing = ->
      Employee.following(
        id : @employee_id
      ).$promise

    # 根据条件Load order
    service.loadOrders = ->
      if (service.filter is 'customer_order_index')
        service.listCustomerOrders()
      else if (service.filter is 'list_history_tasks')
        service.listHistoryTasks()
      else
        EmployeeOrder.query(
          filter    : service.filter
          task_type : service.task_type,
          (orders) =>
            service.orders = orders
        )

    # load各个side bar中order的个数
    service.loadCounts = ->
      EmployeeOrder.counts(
        filters   : service.filters.join(',')
        task_type : service.task_type,
        (counts) => service.counts = counts
        ->
      )

    service.reload =  ->
      service.orders = []
      service.loadOrders().$promise
      .then ->
        _.map service.orders, (order) =>
          order.isConfirmCollapse = true
          order.isInfoCollapse = true

    service.confirm = (order, confirm_type) ->
      service.confirm_type = confirm_type
      order.isConfirmCollapse = false

    service.cancel_confirm = (order) ->
      order.isConfirmCollapse = true
      order.comment = ''

    service.listCustomerOrders = ->
      date = Date.parse(service.search_date)
      opt  = service.options
      EmployeeCustomer.orders(
        cid        : service.customer_id,
        year_month : $filter('date')(date, "yyyy-MM")
        page       : opt.page
        per_page   : opt.pageSize
        action     : service.action,
        (orders, headers) =>
          service.orders = orders
          service.links  = LinkHeader.parse(headers)
        )

    service.listHistoryTasks = ->
      date = Date.parse(service.search_date)
      opt  = service.options
      EmployeeOrder.listHistoryTasks(
        year_month : $filter('date')(date, "yyyy-MM"),
        page       : opt.page
        per_page   : opt.pageSize
        action     : service.action,
        (obts, headers) =>
          _.map obts, (obt) ->
            obt.order.task_type = obt.task_type
            obt.order.task_id = obt.task_id
          service.orders = (obt.order for obt in obts)
          service.links  = LinkHeader.parse(headers)
        )

    service.submit_confirm = (order, index) ->
      switch @confirm_type
        when 'abandon' then abandon(order, index)
        when 'withdraw_reviewer' then withdraw(order, 'Review', index)
        when 'withdraw_qualification' then withdraw(order, 'Qualification', index)
        when 'withdraw_employment' then withdraw(order, 'Employment', index)
        when 'recontact' then recontact(order)
        when 'complained' then customerComplained(order, index)
        when 'expedite' then expedite(order)

    abandon = (order, index) ->
      EmployeeOrder.abandon(
        id        : order.id
        task_type : service.task_type,
        reason    : order.comment
        mistakes  : [],
        ->
          service.orders.splice(index, 1)
          $timeout service.loadCounts, 1000
          Alert.success service.dictionary.abandon.success
        -> Alert.danger service.dictionary.abandon.failed
      )

    recontact = (order) ->
      EmployeeOrder.recontact(
        id        : order.id,
        reason : order.comment
        mistakes  : [],
        ->
          order.isConfirmCollapse = true
          order.comment = ''
          Alert.success service.dictionary.recontact.success
        -> Alert.danger service.dictionary.recontact.failed
      )

    withdraw = (order, task_type, index) ->
      EmployeeOrder.withdraw(
        id        : order.id
        task_type : task_type,
        reason    : order.comment
        mistakes  : [],
        ->
          if service.filter == 'fully_assigned'
            service.orders.splice(index, 1)
            service.loadCounts()
          else
            order.assignees[task_type] = null
            order.comment = ''
            order.isConfirmCollapse = true
          Alert.success service.dictionary.withdraw.success
      )

    customerComplained = (order, index) ->
      EmployeeOrder.customerComplained(
        id       : order.id,
        reason : order.comment
        mistakes : (_.reject service.mistakes, (mistake) -> !mistake),
        ->
          order.isConfirmCollapse = true
          service.mistakes = []
          if (service.filter isnt 'customer_complained' and service.filter isnt 'customer_order_index')
            service.orders.splice(index, 1)
          service.loadCounts()
          Alert.success service.dictionary.customer_complained.success
      )

    expedite = (order) ->
      EmployeeOrder.expedite(
        id       : order.id,
        reason   : order.comment
        mistakes : [],
        ->
          order.isConfirmCollapse = true
          order.attributes.Expedited = order.comment
          order.comment = ''
      )

    service.publish = (order_id) ->
      EmployeeOrder.publish(
        id : order_id
        -> Alert.success service.dictionary.publish.success
      )


    service.take = (order, index) ->
      EmployeeOrder.take(
        id        : order.id
        task_type : service.task_type
        (data, value) ->
          service.orders.splice(index, 1)
          service.loadCounts()
          Alert.success service.dictionary.take.success
        ->
          service.orders.splice(index, 1)
          service.loadCounts()
          Alert.danger service.dictionary.take.failed
      )

    service.remove = (order, index) ->
      EmployeeOrder.remove(
        id     : order.id
        from   : service.filter
        (data, value) ->
          service.orders.splice(index, 1)
          service.loadCounts()
        ->
      )

    service
]

.controller 'EmployeeOrdersCtrl', [
  '$scope'
  'EmployeeOrdersSvc'
  ($scope, EmployeeOrdersSvc) ->
    $scope.EmployeeOrdersSvc = EmployeeOrdersSvc
    $scope.dictionary        = EmployeeOrdersSvc.dictionary
    $scope.jsRoutes          = jsRoutes

    EmployeeOrdersSvc.loadEmployee()

    return
]

.config [
  '$stateProvider'
  ($stateProvider) ->
    $stateProvider
      .state(
        name: '0'
        url: "/support"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('support_side_bar').url
        controller : 'SupportCtrl'
        )
      .state(
        name : '1'
        url: "/qualification"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('qualification_side_bar').url
        controller : 'QualificationCtrl'
        )
      .state(
        name : '2'
        url: "/employment"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('employment_side_bar').url
        controller : 'EmploymentCtrl'
        )
      .state(
        name : '3'
        url: "/review"
        templateUrl : jsRoutes.controllers.EmployeeOrdersCtrl.parts('review_side_bar').url
        controller : 'ReviewCtrl'
        )
]

angular.module('app').requires.push 'employee_orders.index'