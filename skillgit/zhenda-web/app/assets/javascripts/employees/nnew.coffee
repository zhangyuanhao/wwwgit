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

views.employees.nnew = angular.module 'employees.nnew', [
  'api_internal.individual',
  'api_internal.employee',
  'api_internal.user',
  'api.helper',
  'ui.parts',
  'ui.address'
]

.controller 'NewCtrl', [
  '$scope'
  '$filter'
  'Employee'
  'Individual'
  'User'
  'Alert'
  'EmployeeSvc'
  ($scope, $filter, Employee, Individual, User, Alert, EmployeeSvc) ->
    $scope.EmployeeSvc = EmployeeSvc
    $scope.individual  = {}
    $scope.user        = email : ''
    $scope.status      = 'hired'

    $scope.getUsers = (val) ->
      User.query(q : "email:#{val}*").$promise

    $scope.create = (user) ->
      EmployeeSvc.employee.id    = user.id
      # [员工角色]中被选中的角色序列会被保存到数据库
      EmployeeSvc.employee.roles =
        (i for role, i in EmployeeSvc.roles when role)
      Employee.create(
        EmployeeSvc.employee
          -> Alert.success EmployeeSvc.dictionary.message['msg.created']
          (resp) -> Alert.danger resp.data.message
      )

    $scope.$watch 'user', (user) ->
      if user?.id
        Individual.get
          id      : user.id
          indexed : true
          (individual) ->
            $scope.individual = individual
            $scope.individual.id_card_number_detail =
              $scope.individual.id_card_number.join('/')
            EmployeeSvc.employee.nickname =
              $filter('personalName')(individual.personal_name, EmployeeSvc.language)
            EmployeeSvc.employee.personal_name = individual.personal_name

    Employee.nnew().then (resp) ->
      EmployeeSvc.employee = resp.data

    return
]

angular.module('app').requires.push 'employees.nnew'