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

views.customers.orders = angular.module 'customers.orders', [
  'ui.parts'
  'api_internal.employee_customers'
  'api_internal.employee_orders'
  'api.helper'
]

.factory 'OrdersSvc', [
  'EmployeeCustomer'
  'EmployeeOrder'
  'LinkHeader'
  (EmployeeCustomer, EmployeeOrder, LinkHeader) ->
    service                  = {}
    service.links            = LinkHeader.links
    service.orders           = []
    service.action           = 'Place'
    service.customer_id      = ''

    service.load = ->
      EmployeeCustomer.orders(
        cid        : @customer_id
        page       : @page
        per_page   : @pageSize
        action     : @action,
        (orders, headers) =>
          service.orders = orders
          _.map service.orders, (order) =>
            order.isInfoCollapse = true
          service.links  = LinkHeader.parse(headers)
        )

    service.publish = (order_id) ->
      EmployeeOrder.publish(
        id : order_id
      )

    service
]

.controller 'OrdersCtrl', [
  '$scope'
  'Alert'
  'OrdersSvc'
  ($scope, Alert, OrdersSvc) ->
    $scope.OrdersSvc = OrdersSvc

    # load前page数据，不发生页面跳转
    $scope.loadPrevPage = ->
      if OrdersSvc.links.prev
        OrdersSvc.page -= 1
        OrdersSvc.load()

    # load后page数据，不发生页面跳转
    $scope.loadNextPage = ->
      if OrdersSvc.links.next
        OrdersSvc.page += 1
        OrdersSvc.load()

    return
]

angular.module('app').requires.push 'customers.orders'