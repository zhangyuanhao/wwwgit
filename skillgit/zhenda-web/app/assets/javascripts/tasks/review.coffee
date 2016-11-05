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
this.views.tasks ?= {}

views.tasks.review = angular.module 'tasks.review', [
  'ui.parts'
  'api.helper'
  'xeditable'
  'tasks.task_svc'
  'api_internal.task'
]

.controller 'ReviewCtrl', [
  '$scope'
  '$window'
  'Alert'
  'ClientError'
  'TaskSvc'
  'Task'
  ($scope, $window, Alert, ClientError, TaskSvc, Task) ->
    $scope.TaskSvc         = TaskSvc
    $scope.jsRoutes        = jsRoutes
    $scope.comment         = ""
    $scope.popover_content = ""
    $scope.review_confirm  =
      display : "blank.html"
      type    : ""
    $scope.scrollClass     = 'affix-static'

    scrollHandler = ->
      if $window.scrollY > 375
        if $scope.scrollClass is 'affix-static'
          $scope.scrollClass = 'affix-fixed'
          $scope.$apply()
      else
        if $scope.scrollClass is 'affix-fixed'
          $scope.scrollClass =  'affix-static'
          $scope.$apply()

    angular.element($window).on('scroll', scrollHandler)

    $scope.load = (id)->
      TaskSvc.loadTask id
        .then TaskSvc.loadOrder
        .then loadTaskEvent id
        .catch TaskSvc.logProblems

    loadTaskEvent = (task_id)->
      Task.lastEvent(
        task_id
      ).then (last) ->
        TaskSvc.last_comment = last.data.comment if last.data?.action is "ReviewRequest"

    $scope.showReviewComment = (operation)->
      switch operation
        when 'complained' then $scope.review_confirm.display    = "taskCommentWithMistakes.html"
        when 'reject' then $scope.review_confirm.display        = "taskCommentWithMistakes.html"
        when 'partiallyPass' then $scope.review_confirm.display = "taskComment.html"
        when 'basicallyPass' then $scope.review_confirm.display = "taskComment.html"
        when 'finallyPass' then $scope.review_confirm.display   = "taskComment.html"
      $scope.review_confirm.type = operation

    $scope.cancelReviewComment = ->
      $scope.review_confirm.display = "blank.html"
      $scope.review_confirm.type    = ""

    $scope.saveReviewComment = ->
      switch $scope.review_confirm.type
        when 'complained' then complained()
        when 'reject' then reject()
        when 'partiallyPass' then partiallyPass()
        when 'basicallyPass' then basicallyPass()
        when 'finallyPass' then finallyPass()

    finallyPass = ->
      Task.finallyPass(
        id : TaskSvc.task.id,
        content : TaskSvc.task.content
        comment : TaskSvc.task_comment
        mistakes : [],
        ->
          Alert.success TaskSvc.dictionary.msg['msg.finally_pass']
          $scope.cancelReviewComment()
        (resp) -> Alert.danger ClientError.messages(resp)
      )

    basicallyPass = ->
      Task.basicallyPass(
        id : TaskSvc.task.id,
        content : TaskSvc.task.content
        comment : TaskSvc.task_comment
        mistakes : [],
        ->
          Alert.success TaskSvc.dictionary.msg['msg.basically_pass']
          $scope.cancelReviewComment()
        (resp) -> Alert.danger ClientError.messages(resp)
      )

    partiallyPass = ->
      Task.partiallyPass(
        id : TaskSvc.task.id,
        content : TaskSvc.task.content
        comment : TaskSvc.task_comment
        mistakes : [],
        ->
          Alert.success TaskSvc.dictionary.msg['msg.partially_pass']
          $scope.cancelReviewComment()
        (resp) -> Alert.danger ClientError.messages(resp)
      )

    reject = ->
      Task.reject(
        id : TaskSvc.task.id,
        content : TaskSvc.task.content
        comment : TaskSvc.task_comment
        mistakes : _.reject(TaskSvc.mistakes, (mistake) -> !mistake),
        ->
          Alert.success TaskSvc.dictionary.msg['msg.reject']
          $scope.cancelReviewComment()
        (resp) -> Alert.danger ClientError.messages(resp)
      )

    complained = ->
      Task.complained(
        id : TaskSvc.task.id,
        content : TaskSvc.task.content
        comment : TaskSvc.task_comment
        mistakes : _.reject(TaskSvc.mistakes, (mistake) -> !mistake),
        ->
          Alert.success TaskSvc.dictionary.msg['msg.complained']
          $scope.cancelReviewComment()
        (resp) -> Alert.danger ClientError.messages(resp)
      )

    # 打开报告预览
    previewReport = ->
      previewURL = "#{jsRoutes.controllers.BackgroundReportsCtrl.preview(TaskSvc.order.id).url}"
      $window.open(previewURL, '_blank')

    # 保存并打开报告预览
    $scope.saveAndPreview = ->
      TaskSvc.save().$promise
        .then previewReport
        .catch TaskSvc.logProblems

    $scope.load(TaskSvc.task_id)
    return
]

angular.module('app').requires.push 'tasks.review'