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
this.views.my ?= {}

views.my.profile = angular.module 'my.profile', [
  'flow'
]

.controller 'ProfileCtrl', [
  '$scope'
  ($scope) ->
    $scope.jsRoutes  = jsRoutes
    $scope.imgURL    = "#{jsRoutes.controllers.MyCtrl.profileImage().url}?s=64"
    $scope.uploading = false
    $scope.errorMessage = ''

    $scope.onUploaded = (resp) ->
      $scope.uploading = false
      updateImgURL() if resp?

    $scope.onFailed = (resp) ->
      $scope.uploading = false
      $scope.errorMessage = JSON.parse(resp).message if resp?

    updateImgURL = ->
      now = new Date()
      $scope.imgURL = "#{jsRoutes.controllers.MyCtrl.profileImage().url}?cb=#{now.getTime()}&s=64"

    $scope.startUpload = ->
      $scope.uploading = true
      $scope.errorMessage = ''

    return
]

angular.module('app').requires.push 'my.profile'