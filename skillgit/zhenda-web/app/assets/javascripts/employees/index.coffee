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
this.views.employees ?= {}

views.employees.index = angular.module 'employees.index', [
  'api_internal.individual'
  'api_internal.employee'
  'api.helper'
  'ui.parts'
]

views.employees.index

.factory 'EmployeeListSvc', [
  'Individual'
  'Employee'
  'LinkHeader'
  (Individual, Employee, LinkHeader) ->
    service               = {}
    service.links         = LinkHeader.links
    service.values        = []
    service.options       = {}
    service.dictionary    = {}
    service.roles_def     = []
    service.role_index    = ''


    service.reload = (q) ->
      opt = @options
      # 根据[筛选角色]选中的内容，来做成query string, role_index的range是[0..63]
      # 若role_index为undefine则不需要这部分query string
      roles = if @role_index then "AND(roles:#{@role_index})" else ''
      Employee.query(
        page        : opt.page
        per_page    : opt.pageSize
        q           : "((personal_name.full_name:#{ if q then q else '*' })OR(nickname:#{q}*)
                        OR(email:#{q}*)OR(work_phone:#{q}*)
                        OR(home_phone:#{q}*)OR(cell_phone:#{q}*))#{roles}"
        sort        : opt.sort.join(','),
        (value, headers) ->
          LinkHeader.updateLinks opt.nextPage, opt.prevPage, headers
      ).$promise.then (employees) =>
        @values = employees
        _.map employees, (employee) =>
          # 画面显示用的字段
          employee.roles_detail = (@roles_def[i] for i in employee.roles).join('/')
          employee.id_card_number_detail = employee.id_card_number.join('/')

    service
]

.controller 'EmployeesCtrl', [
  '$scope'
  'EmployeeListSvc'
  ($scope, EmployeeListSvc) ->
    $scope.EmployeeListSvc = EmployeeListSvc
    $scope.jsRoutes        = jsRoutes
    $scope.keyword         = ''

    $scope.reloadByRole = ->
      EmployeeListSvc.reload $scope.keyword

    $scope.$watch 'keyword', (nv) ->
      EmployeeListSvc.reload nv

    return
]

angular.module('app').requires.push 'employees.index'