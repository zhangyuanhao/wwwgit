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

views.customers.our_customers = angular.module 'customers.our_customers', [
  'ui.bootstrap'
  'ui.parts'
  'api_internal.employee'
  'api_internal.employee_customers'
  'api_internal.customer'
  'api.helper'
]

.factory 'Models', [
  'Employee'
  'Customer'
  'LinkHeader'
  (Employee, Customer, LinkHeader) ->
    service            = {}
    service.links      = LinkHeader.links
    service.values     = []
    service.options    = {}
    service.show_order = false

    service.load  = ->
      loadEmployee()
        .then loadFollowing
        .then loadCustomers
        .catch logProblems

    loadEmployee = ->
      Employee.get(
        id : service.options.employee_id
      ).$promise.then (value, headers) ->
        service.employee = value
        service.show_order = _.contains(value.roles, 0);

    loadFollowing = ->
      Employee.following(
        id : service.options.employee_id
      ).$promise.then (value, headers) ->
        service.employee.following = value

    loadCustomers = ->
      Customer.query(
        page     : service.options.page
        per_page : service.options.pageSize,
        (values, headers) ->
          LinkHeader.updateLinks service.options.nextPage, service.options.prevPage, headers
          service.values = _.map values, (customer) ->
            customer.isFollowed = _.has service.employee.following, customer.id
            customer
      ).$promise

    logProblems = (fault) ->
      console.log String(fault)

    service
]

.controller 'CustomerListCtrl', [
  '$scope'
  'Employee'
  'EmployeeCustomer'
  'Models'
  ($scope, Employee, EmployeeCustomer, Models) ->
    $scope.Models   = Models
    $scope.jsRoutes = jsRoutes

    $scope.follow = (customer) ->
      employee = Models.employee
      EmployeeCustomer.follow cid : customer.id, ->
        has = _.has employee.following, customer.id
        employee.following[customer.id] = customer.alias if !has
        customer.isFollowed = true

    $scope.unfollow = (customer) ->
      employee = Models.employee
      EmployeeCustomer.unfollow cid : customer.id, ->
        has = _.has employee.following, customer.id
        employee.following = _.omit(employee.following, customer.id) if has
        customer.isFollowed = false

    return
]

angular.module('app').requires.push 'customers.our_customers'