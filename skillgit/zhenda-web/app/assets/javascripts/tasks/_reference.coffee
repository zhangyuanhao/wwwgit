#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

angular.module 'tasks._reference', [
  'tasks.task_svc'
]

.factory 'ReferenceSvc', ->
  service = {}

  service.newRefeInfo = ->
    relationship : null
    how_long     : null
    basic_info :
      name           : null
      phone          : null
      email          : null
      comment        : null
      position_title :
        job_title  : null
        department : null

  service

.controller 'NewReferenceCtrl', [
  '$scope'
  '$uibModalInstance'
  'TaskSvc'
  'ReferenceSvc'
  'idx'
  'referenceType'
  'reference'
  ($scope, $uibModalInstance, TaskSvc, ReferenceSvc, idx, referenceType, reference) ->
    console.log reference
    $scope.TaskSvc       = TaskSvc
    $scope.idx           = idx
    $scope.referenceType = referenceType
    $scope.reference     =
      source              : "FoundByUs"
      reason_for_changing : null
      current             :
        origin     : reference.current.origin
        translated : {}
    $scope.reference.current.translated.zh = ReferenceSvc.newRefeInfo() if TaskSvc.lang.zh
    $scope.reference.current.translated.en = ReferenceSvc.newRefeInfo() if TaskSvc.lang.en

    $scope.nnew = ->
      newReference = angular.copy TaskSvc.task.content.employment.list[idx].interviews[referenceType]
      newReference.reference                     = newReference.reference
      newReference.reference.source              = $scope.reference.source
      newReference.reference.reason_for_changing = $scope.reference.reason_for_changing
      newReference.reference.current             = $scope.reference.current
      # 新建证明人的音频文件为空
      newReference.audio_files              = []
      newReference.remaining.status         = false
      newReference.reference.invalid.status = false
      TaskSvc.task.content.employment.list[idx].interviews[referenceType + "_Copy"] = newReference
      TaskSvc.opinionMessages[idx][referenceType + "_Copy"] = TaskSvc.opinionMessages[idx][referenceType]
      TaskSvc.buildUploadAudioInfo(TaskSvc.task)
      $uibModalInstance.close()

    $scope.cancel = ->
      $uibModalInstance.dismiss 'cancel'
    return
]

.controller 'EditReferenceCtrl', [
  '$scope'
  '$uibModalInstance'
  'TaskSvc'
  'ReferenceSvc'
  'idx'
  'referenceType'
  'reference'
  ($scope, $uibModalInstance, TaskSvc, ReferenceSvc, idx, referenceType, reference) ->
    $scope.TaskSvc       = TaskSvc
    $scope.idx           = idx
    $scope.referenceType = referenceType
    $scope.reference     = angular.copy reference

    $scope.loadReference = ->
      translated = $scope.reference.current.translated
      translated = {} if translated is null
      if $scope.reference.source == "Provided"
        translated.zh = angular.copy reference.current.origin if TaskSvc.lang.zh
        translated.en = angular.copy reference.current.origin if TaskSvc.lang.en
      else
        translated.zh = ReferenceSvc.newRefeInfo() if TaskSvc.lang.zh
        translated.en = ReferenceSvc.newRefeInfo() if TaskSvc.lang.en

    $scope.edit = ->
      saveObject = TaskSvc.task.content.employment.list[idx].interviews[referenceType].reference
      saveObject.source  = $scope.reference.source
      saveObject.current = $scope.reference.current
      if $scope.reference.source == "Provided"
        saveObject.reason_for_changing = null
      else
        saveObject.reason_for_changing = $scope.reference.reason_for_changing
      $uibModalInstance.close()

    $scope.cancel = ->
      $uibModalInstance.close()

    return
]

angular.module('app').requires.push 'tasks._reference'