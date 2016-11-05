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

views.orders.show = angular.module 'orders.show', [
  'api_internal.order',
  'api.helper',
  'ui.parts'
  'orders.order_svc'
]

views.orders.show

.factory 'ShowSvc', [
  'Order'
  'Alert'
  'OrderSvc'
  (Order, Alert, OrderSvc) ->
    service               = {}
    service.dictionary    = {}
    service.order_id      = ''
    service.status        = ''
    service.statuses      = []
    service.editable      = false
    service.tracks        = []
    service.progress_step = ('disabled' for i in [0..4])
    service.days_metrics  = []

    service.load = ->
      loadOrder @order_id
        .then loadTracks
        .catch logProblems

    # 取消订单
    service.cancelOrder = ->
      cancelOrder()
      .then loadTracks
      .catch logProblems

    cancelOrder = ->
      Order.delete(
        id : service.order_id
      ).$promise.then (data) ->
          setStatus data.statuses
          service.editable = false

    loadOrder = (order_id) ->
      Order.get(
        id : order_id
      ).$promise.then (data) ->
          buildDaysMetrics data
          setStatus data.statuses
          # 设置[修改]按钮的enable状态
          arr                     = service.dictionary.status_array
          service.editable        = arr[service.status] < arr['InProgress']
          service.packageName     = data.attributes.PackageName
          # candidate和ServiceSet相关信息交给OrderSvc来处理
          OrderSvc.candidate_info = data.candidate_info
          OrderSvc.loadServiceOptionsSet(data.options_set)

    # 取得订单的跟踪情报
    loadTracks = ->
      Order.tracks service.order_id
        .then (resp) ->
          service.tracks = resp.data

    logProblems = (fault) ->
      Alert.danger fault.data.message

    # 取得当前的status并保存statuses，其中[Canceled]要特殊处理
    setStatus = (statuses) ->
      [first,...]      = statuses
      service.status   = first
      service.statuses = _.reject(statuses, (status) -> status is 'Canceled')
      switch service.statuses[0]
        when 'AwaitingSubmission' then setProgressStep(0)
        when 'CandidateSubmitted' then setProgressStep(1)
        when 'InProgress' then setProgressStep(1)
        when 'OnHold' then setProgressStep(1)
        when 'Reviewing'  then setProgressStep(1)
        when 'BasicallyCompleted' then setProgressStep(2)
        when 'FinallyCompleted' then setProgressStep(3)
        when 'CustomerComplained'
          if (service.statuses[1] && (service.statuses[1] is 'BasicallyCompleted'))
            setProgressStep(1)
            service.days_metrics[1] = "-"
            service.days_metrics[2] = "-"
          else
            setProgressStep(2)
            service.days_metrics[2] = "-"

    # 设置进度
    setProgressStep = (stepNum) ->
      service.progress_step[i]       = 'complete' for i in [0..stepNum]
      service.progress_step[stepNum] = 'active'

    # 做成画面显示用的工作时间
    buildDaysMetrics = (order) ->
      days = [
        order.days_metrics.days_01,
        order.days_metrics.days_12,
        order.days_metrics.days_23
      ]

      if (order.partially_completed_at == order.finally_completed_at)
        days[1] = undefined

      service.days_metrics = (daysToText(a) for a in days)

    # 把天数转换成显示用的字符串
    daysToText = (days) ->
      text = service.dictionary.msg["work_days"]
      switch days
        when undefined then "-"
        when 0 then "< 1 #{text}"
        else "#{days} #{text}"

    service
]

.controller 'ShowCtrl', [
  '$scope'
  'Order'
  'ShowSvc'
  'OrderSvc'
  ($scope, Order, ShowSvc, OrderSvc) ->
    $scope.jsRoutes         = jsRoutes
    $scope.read_only        = 'true'
    $scope.OrderSvc         = OrderSvc
    $scope.ShowSvc          = ShowSvc

    $scope.confirmDelete = ->
      swal(ShowSvc.confirmDelete).then(
        -> ShowSvc.cancelOrder()
        (dismiss) ->
      )

    ShowSvc.load()

    return

]

angular.module('app').requires.push 'orders.show'