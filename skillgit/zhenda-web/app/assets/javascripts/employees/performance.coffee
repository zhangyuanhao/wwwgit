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

views.employees.performance = angular.module 'employees.performance', [
  'ui.parts'
  'api.helper'
  'api_internal.employee'
]

views.employees.performance.factory 'PerformanceSvc', [
  '$filter'
  'Employee'
  'LinkHeader'
  ($filter, Employee, LinkHeader) ->
    service                      = {}
    service.dictionary           = {}
    service.employee_performance = []
    service.search_date          = new Date
    service.hotTable             = undefined

    service.date_picker          =
      opened  : false
      open    : -> this.opened = true
      options :
        mode    : 'month'
        maxDate : new Date
        minMode : 'month'
        showWeeks : false

    service.reload = ->
      date = Date.parse(service.search_date)
      opt  = service.options
      Employee
        .performance
          year_month : $filter('date')(date, "yyyy-MM")
          page       : 1
          per_page   : 10000
        .then (
          (resp) =>
            service.employee_performance = _.map resp.data, (data)->
              data.performance.nick_name = data.nick_name
              data.performance
            service.generateHotTable()
          )

    # 创建／更新 Performance表格
    service.generateHotTable = ->
      # 每一列数据的key
      keys        = [['nick_name']..., (_.keys service.dictionary.metrics_def)...]
      # id为hot_table的element
      container   = document.getElementById('hot_table')
      # 第一行以后的所有行的数据
      rowsData    = _.map service.employee_performance, (data) ->
        _.map keys, (key) -> if (_.has data, key) and (data[key] isnt 0) then data[key] else undefined
      # 第一行显示的文字
      headersText = [[service.dictionary.nick_name]..., (_.values service.dictionary.metrics_def)...]
      # 全部显示内容
      allData     = [[headersText]..., rowsData...]
      # 每行的宽度
      widths      = (80 for i in keys)

      if !service.hotTable
        # 创建Performance表格
        service.hotTable = new Handsontable container, {
          data: allData,
          contextMenu        : true,
          colHeaders         : true,
          rowHeaders         : true,
          manualColumnResize : true,
          className          : "htCenter",
          colWidths          : widths,
          fixedColumnsLeft   : 1,
          rowHeights         : (index) -> if index is 0 then 250
        }
      else
        # 更新表格数据
        service.hotTable.loadData(allData)


      # 设置单元格属性，例如readOnly／Alignment
      service.hotTable.updateSettings({
        cells: (row, col, prop) ->
          cellProperties = {}
          if (row is 0 or col is 0) then cellProperties.readOnly = true
          if (col is 0 and row isnt 0) then cellProperties.className = 'htLeft'
          cellProperties
      })

    service
]

.controller 'PerformanceCtrl', [
  '$scope'
  'PerformanceSvc'
  'Alert'
  ($scope, PerformanceSvc, Alert) ->
    $scope.PerformanceSvc = PerformanceSvc
    $scope.dictionary     = PerformanceSvc.dictionary

    $scope.index = ->
      PerformanceSvc.reload()

    PerformanceSvc.reload()

    return
]

angular.module('app').requires.push 'employees.performance'