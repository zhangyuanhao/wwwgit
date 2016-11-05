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

views.customers.invoice = angular.module 'customers.invoice', [
  'ui.parts'
  'ui.bootstrap'
  'api_internal.customer'
  'api.helper'
]

views.customers.invoice.factory 'InvoiceSvc', [
  '$filter'
  'Customer'
  'LinkHeader'
  ($filter, Customer, LinkHeader) ->
    service               = {}
    service.links         = LinkHeader.links
    service.order_metrics = []
    service.actions_def   = {}
    service.action        = 'FinallyCompleted'
    service.options       = {}
    service.dictionary    = {}
    service.customer_id   = ''
    service.search_date   = new Date
    service.date_picker   =
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

    # 进行reload处理，重新load所有的信息
    service.reload = ->
      date = Date.parse(service.search_date)
      opt  = service.options
      Customer.invoice(
        id         : service.customer_id
        year_month : $filter('date')(date, "yyyy-MM")
        page       : opt.page
        per_page   : opt.pageSize
        action     : service.action,
        (orders, headers) =>
          service.orders = orders
          service.links  = LinkHeader.parse(headers)
      )

    service
]

.controller 'InvoiceCtrl', [
  '$scope'
  'InvoiceSvc'
  'Alert'
  ($scope, InvoiceSvc, Alert) ->
    $scope.InvoiceSvc = InvoiceSvc
    $scope.dictionary = InvoiceSvc.dictionary
    $scope.jsRoutes   = jsRoutes

    $scope.index = ->
      InvoiceSvc.orders       = []
      InvoiceSvc.options.page = 1
      InvoiceSvc.reload()

    # load前page数据，不发生页面跳转
    $scope.loadPrevPage = ->
      if InvoiceSvc.links.prev
        InvoiceSvc.options.page -= 1
        InvoiceSvc.reload()

    # load后page数据，不发生页面跳转
    $scope.loadNextPage = ->
      if InvoiceSvc.links.next
        InvoiceSvc.options.page += 1
        InvoiceSvc.reload()

    InvoiceSvc.reload()

    return
]

angular.module('app').requires.push 'customers.invoice'