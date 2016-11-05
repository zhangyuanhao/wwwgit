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

views.tasks.task = angular.module 'tasks.task', [
  'ui.parts'
  'api.helper'
  'xeditable'
  'tasks.task_svc'
  'api_internal.task'
  'flow'
]

.config ['flowFactoryProvider'
  (flowFactoryProvider) ->
    flowFactoryProvider.defaults =
      target              : ''
      permanentErrors     : [404, 500, 501]
      maxChunkRetries     : 1
      chunkRetryInterval  : 5000
      testChunks          : true
      simultaneousUploads : 1
]

.controller 'TaskCtrl', [
  '$scope'
  '$window'
  '$uibModal'
  '$timeout'
  'ClientError'
  'Alert'
  'TaskSvc'
  'Task'
  ($scope, $window, $uibModal, $timeout, ClientError, Alert, TaskSvc, Task) ->
    $scope.TaskSvc         = TaskSvc
    $scope.jsRoutes        = jsRoutes
    $scope.popover_content = ""
    $scope.scrollClass     = 'affix-static'

    audioKey = (reference_type, employment_index, audio_index) ->
      "#{employment_index}_#{reference_type}_#{audio_index}"

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

    $scope.audioKey = (reference_type, employment_index, audio_index) ->
      audioKey(reference_type, employment_index, audio_index)

    $scope.load = (id)->
      TaskSvc.loadTask id
        .then TaskSvc.loadOrder
        .then loadTaskEvent id
        .catch TaskSvc.logProblems

    $scope.newReference = (idx, referenceType) ->
      if !TaskSvc.task.content.employment.list[idx].interviews[referenceType + "_Copy"]?
        reference     = TaskSvc.task.content.employment.list[idx].interviews[referenceType].reference
        modalInstance = $uibModal.open(
          templateUrl : 'NewReference.html'
          controller  : 'NewReferenceCtrl'
          resolve     :
            idx           : -> idx
            referenceType : -> referenceType
            reference     : -> reference
        )

    $scope.changeReference = (idx, referenceType) ->
      reference     = TaskSvc.task.content.employment.list[idx].interviews[referenceType].reference
      modalInstance = $uibModal.open(
        templateUrl : 'EditReference.html'
        controller  : 'EditReferenceCtrl'
        resolve     :
          idx           : -> idx
          referenceType : -> referenceType
          reference     : -> reference
      )

    $scope.deleteReference = (idx, referenceType) ->
      delete TaskSvc.task.content.employment.list[idx].interviews[referenceType]
      delete TaskSvc.opinionMessages[idx][referenceType]

    loadTaskEvent = (task_id)->
      Task.lastEvent(
        task_id
      ).then (last) ->
        TaskSvc.last_comment = last.data.comment if last.data?.action is "ReviewPartiallyPass" || last.data?.action is "ReviewReject"

    $scope.reviewRequest = ->
      Task.reviewRequest(
        id : TaskSvc.task.id,
        content : TaskSvc.task.content
        comment : TaskSvc.task_comment
        mistakes : [],
        -> Alert.success TaskSvc.dictionary.msg['msg.review_request']
        (resp) -> Alert.danger ClientError.messages(resp)
      )

    # 上传录音文件
    $scope.uploadAudio = (flow, reference_type, employment_index, audio_index) ->
      filename         = "#{employment_index + 1}_#{reference_type}_#{audio_index + 1}.mp3"
      flow.opts.target =
        "#{jsRoutes.controllers.EmployeeOrdersCtrl.uploadAudio(TaskSvc.order_id, TaskSvc.task_id, filename).url}"
      flow.upload()

    $scope.flowProgress = ($flow, reference_type, employment_index, audio_index) ->
      key = audioKey(reference_type, employment_index, audio_index)
      TaskSvc.audio_info[key].upload_progress = Math.min(0.99, $flow.progress())

    # 上传完成后的动作
    $scope.onAudioUploaded = (resp, reference_type, employment_index, audio_index) ->
      key         = audioKey(reference_type, employment_index, audio_index)
      parsed_resp = JSON.parse(resp) if resp?
      # 更新audio_file
      updateAudioFile(parsed_resp, reference_type, employment_index, audio_index, key)
      # 更新播放和显示用的数据
      $timeout updateUploadAudioInfo, 500, true, parsed_resp, key

    $scope.flowComplete = ($flow, reference_type, employment_index, audio_index) ->
      key = audioKey(reference_type, employment_index, audio_index)
      TaskSvc.audio_info[key].upload_progress = 1
      $flow.cancel()

    updateUploadAudioInfo = (resp, key) ->
      # 重新加载src
      TaskSvc.audio_info[key].src          = ""
      audio                                = document.getElementById(key)
      audio.load()
      TaskSvc.audio_info[key].src =
        "#{jsRoutes.controllers.EmployeeOrdersCtrl.streamAudio(TaskSvc.order_id, resp.name).url}"

    updateAudioFile = (resp, reference_type, employment_index, audio_index, key) ->
      TaskSvc.audio_info[key].uploading    = false
      TaskSvc.audio_info[key].errorMessage = ''
      employmentList                       = TaskSvc.task.content?.employment?.list
      audio_files                          = employmentList[employment_index]?.interviews[reference_type]?.audio_files
      audio_files[audio_index]             = {} if !audio_files[audio_index]
      audio_files[audio_index].filename    = resp.name
      audio_files[audio_index].comment     = null
      # 如果更新的是最后一个audio_file，那么追加一个空的audio_file
      if (audio_index is (audio_files.length - 1))
        newKey = "#{employment_index}_#{reference_type}_#{audio_files.length}"
        TaskSvc.audio_info[newKey] = TaskSvc.initAudioInfo("")

    # 上传失败时的动作
    $scope.onAudioFailed = (resp, reference_type, employment_index, audio_index) ->
      key                                  = audioKey(reference_type, employment_index, audio_index)
      TaskSvc.audio_info[key].uploading    = false
      TaskSvc.audio_info[key].errorMessage = JSON.parse(resp).message if resp?

    # 开始上传时的动作
    $scope.startUploadAudio = (reference_type, employment_index, audio_index) ->
      key                                    = audioKey(reference_type, employment_index, audio_index)
      TaskSvc.audio_info[key].uploading      = true
      TaskSvc.audio_info[key].upload_progress = 0
      TaskSvc.audio_info[key].errorMessage = ''

    $scope.load(TaskSvc.task_id)
    return
]

angular.module('app').requires.push 'tasks.task'