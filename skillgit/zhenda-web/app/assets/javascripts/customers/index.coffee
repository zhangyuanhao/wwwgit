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

views.customers.index = angular.module 'customers.index', [
  'ui.bootstrap'
  'ui.parts'
  'api_internal.customer'
  'api.helper'
]

.factory 'CustomerList', [
  'Customer'
  'LinkHeader'
  (Customer, LinkHeader) ->
    service         = {}
    service.links   = LinkHeader.links
    service.values  = []
    service.options = {}

    buildQueryString = (q) ->
      if q
        "(name:#{q})OR(phone:#{q}*)"
      else
        "(name:*)OR(phone:*)"

    service.reload  = (q) ->
      opt            = service.options
      queryString    = buildQueryString(q)
      service.values = Customer.query
        page     : opt.page
        per_page : opt.pageSize
        q        : queryString
        sort     : opt.sort.join(','),
        (values, headers) ->
          LinkHeader.updateLinks opt.nextPage, opt.prevPage, headers

    service
]

.controller 'CustomerListCtrl', [
  '$scope'
  'CustomerList'
  ($scope, CustomerList) ->
    $scope.jsRoutes = jsRoutes
    $scope.List     = CustomerList
    $scope.keyword  = ''
    $scope.$watch 'keyword', (nv) ->
      CustomerList.reload nv

    return
]

angular.module('app').requires.push 'customers.index'