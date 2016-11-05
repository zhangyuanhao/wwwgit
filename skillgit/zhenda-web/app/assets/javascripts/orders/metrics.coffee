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
this.views.orders ?= {}

views.orders.metrics = angular.module 'orders.metrics', [
  'ui.bootstrap'
  'ui.parts'
  'api.helper'
  'api_internal.order'
  'orders.echarts_options'
]

views.orders.metrics.factory 'OrderMetricsSvc', [
  '$filter'
  'Alert'
  'Order'
  ($filter, Alert, Order) ->
    service                       = {}
    service.dictionary            = {}
    service.customer_id           = ''
    service.start_date            = new Date
    service.end_date              = new Date
    service.start_date_picker     = {}
    service.end_date_picker       = {}
    service.monthly_orders_counts = {}
    service.yearly_on_time_ratio  = {}
    service.risk_reports_ratio    = {}
    service.yearly_lights_ratio   = {}
    service.yearly_modules_ratio  = {}

    newDatepicker = ->
      max    : new Date
      opened : false
      open   : -> this.opened = true

    service.loadMonthlyOrdersCounts = ->
      years = (new Date().getFullYear() - i for i in [2..0])
      Order
        .monthlyOrdersCounts
          years  : years.join(',')
          action : 'Place'
        .then (
          (resp) ->
            service.monthly_orders_counts = resp.data
          )

    service.loadYearlyOnTimeRatio = ->
      Order
        .yearlyOnTimeRatio
          year : new Date().getFullYear()
        .then (
          (resp) ->
            service.yearly_on_time_ratio = resp.data
          )

    service.loadRiskReportsRatio = ->
      years = (new Date().getFullYear() - i for i in [2..0])
      Order
        .riskReportsRadio
          years  : years.join(',')
        .then (
          (resp) ->
            service.risk_reports_ratio = resp.data
          )

    service.loadYearlyLightsRatio = ->
      Order
        .yearlyLightsRatio
          year : new Date().getFullYear()
        .then (
          (resp) ->
            service.yearly_lights_ratio = resp.data
          )

    service.loadYearlyModulesRatio = ->
      Order
        .yearlyModulesRatio
          year : new Date().getFullYear()
        .then (
          (resp) ->
            service.yearly_modules_ratio = resp.data
          )

    service
]

.controller 'OrderMetricsCtrl', [
  '$scope'
  '$window'
  'OrderMetricsSvc'
  'Alert'
  'echartsOptions'
  ($scope, $window, OrderMetricsSvc, Alert, echartsOptions) ->
    $scope.OrderMetricsSvc              = OrderMetricsSvc
    $scope.dictionary                   = OrderMetricsSvc.dictionary
    $scope.show_delay                   = false
    $scope.monthly_orders_counts =
      echarts.init(document.getElementById('monthly_orders_counts'))
    $scope.yearly_on_time_ratio =
      echarts.init(document.getElementById('yearly_on_time_ratio'))
    $scope.risk_reports_ratio =
      echarts.init(document.getElementById('risk_reports_ratio'))
    $scope.lights_ratio =
      echarts.init(document.getElementById('lights_ratio'))
    $scope.modules_ratio =
      echarts.init(document.getElementById('modules_ratio'))
    $scope.monthly_orders_counts_option = echartsOptions.monthly_orders_counts_option
    $scope.yearly_on_time_ratio_option  = echartsOptions.yearly_on_time_ratio_option
    $scope.risk_reports_ratio_option    = echartsOptions.risk_reports_ratio_option
    $scope.lights_ratio_option          = echartsOptions.lights_ratio_option
    $scope.modules_ratio_option         = echartsOptions.lights_ratio_option

    $scope.generateMonthlyOrdersCount = ->
      baseOption             = $scope.monthly_orders_counts_option.baseOption
      monthly_orders_counts  = $scope.OrderMetricsSvc.monthly_orders_counts
      baseOption.legend.data = monthly_orders_counts.legend.data
      baseOption.xAxis.data  = monthly_orders_counts.xAxis.data
      baseOption.series      = monthly_orders_counts.series
      $scope.monthly_orders_counts.setOption($scope.monthly_orders_counts_option)

    $scope.generateYearlyOnTimeRatio = ->
      option                = $scope.yearly_on_time_ratio_option
      yearly_on_time_ratio  = $scope.OrderMetricsSvc.yearly_on_time_ratio
      option.legend.data    = yearly_on_time_ratio.legend.data
      option.series[0].name = $scope.dictionary['abstract']
      option.series[0].data = yearly_on_time_ratio.series[0].data
      option.series[1].name = $scope.dictionary['details']
      option.series[1].data = yearly_on_time_ratio.series[1].data

      $scope.yearly_on_time_ratio.setOption(option)

    $scope.generateRiskReportsRatio = ->
      ratios                = $scope.OrderMetricsSvc.risk_reports_ratio
      option                = $scope.risk_reports_ratio_option.baseOption
      option.xAxis.data     = ratios.xAxis.data
      option.legend.data[0] = $scope.dictionary['risk_reports_ratio']
      option.series[0].name = $scope.dictionary['risk_reports_ratio']
      option.series[0].data = ratios.series[0].data
      $scope.risk_reports_ratio.setOption($scope.risk_reports_ratio_option)

    $scope.generateLightsRatio = ->
      ratios                = $scope.OrderMetricsSvc.yearly_lights_ratio
      option                = $scope.lights_ratio_option
      option.legend.data    = ratios.legend.data
      option.series[0].data = ratios.series[0].data
      option.series[0].data = _.map option.series[0].data, $scope.addColors
      option.title.text     = $scope.dictionary['lights_ratio']
      option.series[0].name = $scope.dictionary['lights']

      $scope.lights_ratio.setOption(option)

    $scope.generateModulesRatio = ->
      ratios   = $scope.OrderMetricsSvc.yearly_modules_ratio
      option = $scope.modules_ratio_option
      option.legend.data = ratios.legend.data
      option.series[0].data = ratios.series[0].data
      option.title.text = $scope.dictionary['modules_ratio']
      option.series[0].name = $scope.dictionary['modules']

      $scope.modules_ratio.setOption(option)

    $scope.addColors = (object) ->
      switch object.name
        when $scope.dictionary['danger'] then object.itemStyle = normal : color : '#9f5353'
        when $scope.dictionary['warning'] then object.itemStyle = normal : color : '#d2973d'
        when $scope.dictionary['info'] then object.itemStyle = normal : color : '#4b86b4'
        when $scope.dictionary['safe'] then object.itemStyle = normal : color : '#abe5ad'
      object

    $scope.onWindowResize = ->
      $scope.monthly_orders_counts.resize()
      $scope.yearly_on_time_ratio.resize()
      $scope.risk_reports_ratio.resize()
      $scope.lights_ratio.resize()
      $scope.modules_ratio.resize()


    OrderMetricsSvc.loadMonthlyOrdersCounts()
    .then $scope.generateMonthlyOrdersCount

    OrderMetricsSvc.loadYearlyOnTimeRatio()
    .then $scope.generateYearlyOnTimeRatio

    OrderMetricsSvc.loadRiskReportsRatio()
    .then $scope.generateRiskReportsRatio

    OrderMetricsSvc.loadYearlyLightsRatio()
    .then $scope.generateLightsRatio

    OrderMetricsSvc.loadYearlyModulesRatio()
    .then $scope.generateModulesRatio

    angular.element($window).bind('resize', $scope.onWindowResize)

    return
]

angular.module('app').requires.push 'orders.metrics'