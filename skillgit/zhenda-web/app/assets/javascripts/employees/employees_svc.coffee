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

views.employees.employee_svc = angular.module 'employees.employee_svc', []

views.employees.employee_svc.factory 'EmployeeSvc', [
  'Employee'
  'Alert'
  (Employee, Alert) ->
    service                  = {}
    service.roles_def        = {}  # 角色名称
    service.roles            = []  # 与画面上［员工角色］的checkbox绑定的bool数组
    service.levels_def       = []  # Level的value定义
    service.roles_levels_def = []  # 角色于Level对应的名字定义
    service.employee         = {}
    service.dictionary       = {}
    service.id               = ''

    buildRoles = (roles) ->
      service.roles[i] = true for i in roles

    service.load = ->
      Employee.get id : @id,
        (resp) =>
          @employee = resp
          buildRoles resp.roles

    service.changeLevel = (index) ->
      @employee.roles_levels[index] = switch @roles[index]
        when true then @levels_def[0]
        when false then 'unknown'

    service.initRoles = (roles_def) ->
      @roles_def = roles_def
      @roles     = (false for role in roles_def)

    service.noRoles = ->
      return false for i in service.roles when i is true
      return true

    service
]

angular.module('app').requires.push 'employees.employee_svc'