#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

#
# Common UI Parts.
#
angular.module 'ui.parts', [
  'ui.parts.toggle-switch'
  'ui.parts.f-validate'
  'ui.multi-check'
  'ngAnimate'
]

#
# Helper to make alert easier to use.
# msg format: {type:'danger', msg:'msg'}
#
.factory 'Alert', ->
  alerts :
    success : []
    info    : []
    warning : []
    danger  : []

  dismiss : (type, idx) ->
    @alerts.success.splice idx, 1 if type is 'success'
    @alerts.info.splice idx, 1 if type is 'info'
    @alerts.warning.splice idx, 1 if type is 'warning'
    @alerts.danger.splice idx, 1 if type is 'danger'

  show    : (type, arg) ->
    messages = if _.isArray(arg) then arg else [arg]
    @push(type : type, msg : msg) for msg in messages

  push    : (alert) ->
    alert.type ?= 'info'
    @alerts.success.push alert if alert.type is 'success'
    @alerts.info.push alert if alert.type is 'info'
    @alerts.warning.push alert if alert.type is 'warning'
    @alerts.danger.push alert if alert.type is 'danger'

  success : (msg) -> @show 'success', msg
  info    : (msg) -> @show 'info'   , msg
  warning : (msg) -> @show 'warning', msg
  danger  : (msg) -> @show 'danger' , msg

.controller 'AlertCtrl', ['$scope', 'Alert', ($scope, Alert) ->
  $scope.Alert = Alert
  return
]

#
# Helper to make confirm message box easier to use.
#
.factory 'ModalDialog', [
  '$uibModal'
  ($uibModal) ->
    service  = {}
    service.templateUrl = ''
    service.open = -> $uibModal.open
      templateUrl : service.templateUrl
      controller  : 'ModalDialogCtrl'
    service
]

.controller 'ModalDialogCtrl', [
  '$scope'
  '$uibModalInstance'
  ($scope, $uibModalInstance) ->
    $scope.ok =
      -> $uibModalInstance.close()
    $scope.cancel =
      -> $uibModalInstance.dismiss 'cancel'
    return
]

#
# Toggle switch button - iOS style.
#
angular.module 'ui.parts.toggle-switch', [ 'ui.template/buttons/toggle-switch.html' ]

.controller 'ToggleSwitchController', [ '$scope', ($scope) ->
  $scope.toggle = ->
    $scope.status = !$scope.status
    return
  return
]

.directive 'toggleSwitch', ->
  restrict    : 'E'
  scope       :
    status : '='
  controller  : 'ToggleSwitchController'
  templateUrl : 'ui.template/buttons/toggle-switch.html'

angular.module 'ui.template/buttons/toggle-switch.html', []

.run [
  '$templateCache'
  ($templateCache) ->
    $templateCache.put(
      'ui.template/buttons/toggle-switch.html',
      """
      <div class="toggle-switch">
        <i class="fa fa-2x fa-toggle-on"
           ng-class="status?'active':'inactive fa-rotate-180'"
          ng-click="toggle()">
        </i>
      </div>
      """)
    return
]

#
# 非Map结构多项选择用directive
#
angular.module 'ui.multi-check', ['ui.multi-check.html']

.controller 'MultiCheckController', [ '$scope', ($scope) ->
  $scope.check_map = {}
  $scope.checks    = [] if !$scope.checks?

  $scope.initCheckMap = (defs, checks)->
    _.mapObject defs, (val, key) ->
      if _.contains(checks, key)
        $scope.check_map[key] = true
      else
        $scope.check_map[key] = false

  $scope.selectCheckMap = ->
    $scope.checks    = []
    _.mapObject $scope.check_map, (val, key) ->
      $scope.checks.push key if val is true

  return
]

.directive 'multiCheck', ->
  restrict : 'E'
  require  : ['?ngModel', '?checksDef']
  scope    :
    checks     : '=ngModel'
    checks_def : '=checksDef'
  controller  : 'MultiCheckController'
  templateUrl : 'multi-checks.html'
  link        : (scope, element, attr, ctrl) ->
    scope.formName    = attr.formName || 'form'
    scope.name        = attr.name || 'address'
    scope.initCheckMap(scope.checks_def, scope.checks)

angular.module 'ui.multi-check.html', []

.run [
  '$templateCache'
  ($templateCache) ->
    $templateCache.put(
      'multi-checks.html',
      """
        <div class="checkbox checkbox-success checkbox-inline" ng-repeat="(k, v) in checks_def">
          <input type="checkbox" id="{{name + k}}" class="styled"
            ng-model="check_map[k]" ng-click="selectCheckMap()">
          <label for="{{name + k}}">
            {{v}}
          </label>
        </div>
      """)
    return
]

#
# 改写表单校验用的directive
#
angular.module 'ui.parts.f-validate', []

.directive 'frequired', ->
  restrict : 'A'
  require  : '?ngModel'
  link     : (scope, element, attr, ctrl) ->
    return if !ctrl
    attr.frequired = true
    scope.$watch attr.novalidate, (v) ->
      ctrl.$validators.required = (modelValue, viewValue) ->
        v || !attr.frequired || !ctrl.$isEmpty(viewValue)

      attr.$observe 'frequired', ->
        ctrl.$validate()

.directive 'novalidate', ->
  restrict : 'A'
  require  : '?ngModel'
  priority: 600
  link     : (scope, element, attr, ctrl) ->
    true

.directive 'fpattern', ->
  restrict : 'A'
  require  : '?ngModel'
  link     : (scope, element, attr, ctrl) ->
    return if !ctrl
    regexp = attr.ngPattern || attr.pattern
    patternExp = regexp
    scope.$watch attr.novalidate, (v) ->
      attr.$observe 'fpattern', (regex) ->
        if typeof regex == 'string' && regex.length > 0
          regex = new RegExp('^' + regex + '$')
        if regex && !regex.test
          throw minErr('ngPattern')('noregexp',
            'Expected {0} to be a RegExp but was {1}. Element: {2}', patternExp,
            regex, startingTag(element))
        regexp = regex || undefined
        ctrl.$validate()
      ctrl.$validators.pattern = (value) ->
        v || ctrl.$isEmpty(value) || typeof regexp == 'undefined' || regexp.test(value)

.directive 'fminlength', ->
  restrict : 'A'
  require  : '?ngModel'
  link     : (scope, element, attr, ctrl) ->
    return if !ctrl
    minlength = 0;
    scope.$watch attr.novalidate, (v) ->
      attr.$observe 'fminlength', (value) ->
        minlength = parseInt(value,10) || 0
        ctrl.$validate()
      ctrl.$validators.minlength = (modelValue, viewValue) ->
        v || ctrl.$isEmpty(viewValue) || (viewValue.length >= minlength)