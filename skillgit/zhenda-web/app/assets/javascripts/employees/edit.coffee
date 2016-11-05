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

views.employees.edit = angular.module 'employees.edit', [
  'api_internal.individual',
  'api_internal.employee',
  'api.helper',
  'ui.parts',
  'ui.address'
]

.controller 'EditCtrl', [
  '$scope'
  'Employee'
  'EmployeeSvc'
  'Alert'
  'Individual'
  ($scope, Employee, EmployeeSvc, Alert, Individual) ->
    $scope.EmployeeSvc = EmployeeSvc
    $scope.status      = 'hired'
    $scope.status_old  = ''
    $scope.individual  = {}

    $scope.save = ->
      # 当员工角色被勾选时，选中的角色序列会被保存到数据库
      EmployeeSvc.employee.roles =
        (i for role, i in EmployeeSvc.roles when role)
      EmployeeSvc.employee.$save(
        -> Alert.success EmployeeSvc.dictionary.message['msg.saved']
        (resp) -> Alert.danger resp.data.message
      )

    $scope.rehire = ->
      # 点击[在职]Button时，休假类型应该为空
      EmployeeSvc.employee.leave_of_absence = null
      # 仅当变更前的状态是离职时，才会触发[再入职]处理
      if $scope.status_old is 'resigned'
        Employee.rehire id : EmployeeSvc.id,
          -> $scope.status_old = $scope.status

    $scope.resign = ->
      # 点击[离职]Button时，休假类型应该为空
      EmployeeSvc.employee.leave_of_absence = null
      # 仅当变更前的状态是在职时，才会触发[离职]处理
      if $scope.status_old isnt 'resigned'
        Employee.resign id : EmployeeSvc.id,
          -> $scope.status_old = $scope.status

    $scope.buildStatus = (hire_status, leave_of_absence) ->
      # 有休假的时候，是休假状态
      # 没有休假的时候，雇佣状态是入职，则是在职状态。
      # 否则是离职状态
      if !leave_of_absence
        switch hire_status
          when 'New', 'ReadyForHire', 'Hired' then 'hired'
          else 'resigned'
      else 'leave_of_absence'

    $scope.loadIndividual = ->
      Individual.get
        id      : EmployeeSvc.id
        indexed : true
        (individual) ->
          $scope.individual = individual

    EmployeeSvc.load().$promise
      .then ->
        $scope.status     =
          $scope.buildStatus(EmployeeSvc.employee.hire_status,
                             EmployeeSvc.employee.leave_of_absence)
        $scope.status_old = $scope.status
        $scope.loadIndividual()

    return
]

angular.module('app').requires.push 'employees.edit'