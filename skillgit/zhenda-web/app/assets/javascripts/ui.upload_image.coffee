#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

angular.module 'ui.upload_image', ['ui.upload_image.html']

.constant 'uploadImageConfig', {
  'upload_title'        : ''
  'original_image'      : ''
  'image_format'        : ''
  'image_size'          : ''
  'btn_upload'          : ''
  'btn_uploading'       : ''
  'comment_placeholder' : ''
  'error_exists'        : ''
}

.controller 'UploadController', [
  '$scope'
  ($scope) ->
    $scope.upload_info = {}
    $scope.msg         = {}

    imageKey = (idx) ->
      $scope.name + "_" + $scope.moduleName + "_" + $scope.moduleIndex + "_" + idx

    $scope.imageKey = (idx) -> imageKey(idx)

    # 做成上传及显示用的数据结构
    $scope.initUpload = ->
      $scope.upload_info[imageKey(i)] = $scope.initUploadInfo($scope.images[i].filename) for i in [0..$scope.images.length-1] if $scope.images?.length > 0
      $scope.upload_info[imageKey($scope.images.length)] = $scope.initUploadInfo("")

    $scope.initUploadInfo = (fileName) ->
      src             : $scope.fnSrcUrl({fName : fileName}) + '&' + new Date().getTime()
      thumbnail       : $scope.fnThumbnailUrl({fName : fileName}) + '&' + new Date().getTime()
      uploading       : false
      upload_progress : 0
      errorMessage    : ''

    # 上传图片
    $scope.onUpload = (flow, fileIndex) ->
      filename         = "#{$scope.name}_#{$scope.moduleName}_#{$scope.moduleIndex + 1}_#{fileIndex + 1}"
      flow.opts.target = $scope.fnUploadUrl({fName : filename})
      flow.upload()

    $scope.flowProgress = ($flow, fileIndex) ->
      $scope.upload_info[imageKey(fileIndex)].upload_progress = Math.min(0.99, $flow.progress())

    # 图片上传成功时的处理
    $scope.onUploaded = (resp, fileIndex) ->
      parsed_resp = JSON.parse(resp) if resp?
      # 更新显示用的数据
      updateUploadAttachment(parsed_resp, imageKey(fileIndex))
      # 更新images
      updateAttachments(parsed_resp, fileIndex)

    $scope.flowComplete = ($flow, fileIndex) ->
      $scope.upload_info[imageKey(fileIndex)].upload_progress = 1
      $flow.cancel()

    updateUploadAttachment = (resp, key) ->
      $scope.upload_info[key].uploading    = false
      $scope.upload_info[key].errorMessage = ''
      $scope.upload_info[key].src          = $scope.fnSrcUrl({fName : resp.name}) + '&' + new Date().getTime()
      $scope.upload_info[key].thumbnail    = $scope.fnThumbnailUrl({fName : resp.name}) + '&' + new Date().getTime()

    updateAttachments = (resp, fileIndex) ->
      $scope.images[fileIndex]          = {} if !$scope.images[fileIndex]
      $scope.images[fileIndex].filename = resp.name
      $scope.images[fileIndex].comment  = null
      if fileIndex is ($scope.images.length - 1)
        $scope.upload_info[imageKey($scope.images.length)] = $scope.initUploadInfo("")

    # Attachment上传失败时的处理
    $scope.onFailed = (resp, fileIndex) ->
      $scope.upload_info[imageKey(fileIndex)].uploading    = false
      $scope.upload_info[imageKey(fileIndex)].errorMessage = JSON.parse(resp).message if resp?

    # Attachment开始上传时的处理
    $scope.startUpload = (fileIndex) ->
      $scope.upload_info[imageKey(fileIndex)].uploading       = true
      $scope.upload_info[imageKey(fileIndex)].upload_progress = 0

    $scope.isUploading = (fileIndex) ->
      $scope.upload_info[imageKey(fileIndex)]?.uploading

    $scope.getErrorMessage = (fileIndex) ->
      $scope.upload_info[imageKey(fileIndex)]?.errorMessage

    $scope.thumbnailPath = (fileIndex) ->
      $scope.upload_info[imageKey(fileIndex)]?.thumbnail

    $scope.originPath = (fileIndex) ->
      $scope.upload_info[imageKey(fileIndex)]?.src

    return
  ]

.directive 'uploadImage', [ 'uploadImageConfig', (uploadImageConfig) ->
  restrict   : 'E'
  require    : '?ngModel'
  transclude : true
  scope      :
    images         : '=ngModel'
    fnUploadUrl    : '&uploadFn'
    fnSrcUrl       : '&srcFn'
    fnThumbnailUrl : '&thumbnailFn'
  controller  : 'UploadController'
  templateUrl : 'upload_image.html'
  link        : (scope, element, attr, ctrl) ->
    scope.formName     = attr.formName || 'form'
    scope.title        = attr.title
    scope.name         = attr.name
    scope.moduleName   = attr.moduleName
    scope.moduleIndex  = parseInt(attr.moduleIndex)
    scope.srcUrl       = attr.srcUrl
    scope.thumbnailUrl = attr.thumbnailUrl
    scope.uploadUrl    = attr.uploadUrl
    scope.no_more      = attr.noMore || 'false'

    scope.msg.original_image         = uploadImageConfig.original_image
    scope.msg.image_format           = uploadImageConfig.image_format
    scope.msg.image_size             = uploadImageConfig.image_size
    scope.msg.btn_modify             = uploadImageConfig.btn_modify
    scope.msg.btn_upload             = uploadImageConfig.btn_upload
    scope.msg.btn_uploading          = uploadImageConfig.btn_uploading
    scope.msg.comment_placeholder    = uploadImageConfig.comment_placeholder
    scope.msg.error_exists           = uploadImageConfig.error_exists
    scope.layout_type                = uploadImageConfig.layout_type || 'edit'

    scope.initUpload()

]

angular.module 'ui.upload_image.html', []
.run [
  '$templateCache'
  ($templateCache) ->
    $templateCache.put(
      'upload_image.html',
      """
      <div class="row" ng-show="layout_type === 'edit'">
        <div class="col-xs-12 col-sm-12">
          <label>{{title}}</label>
        </div>
      </div>
      <div class="row">
        <div ng-repeat="image in images"
          ng-init="file_index = $index">
          <div class="col-xs-12 col-sm-6">
            <div flow-init
                 flow-files-submitted="onUpload($flow, file_index)"
                 flow-upload-started="startUpload(file_index)"
                 flow-file-success="onUploaded($message, file_index)"
                 flow-file-error="onFailed($message, file_index)"
                 flow-progress="flowProgress($flow, file_index)"
                 flow-complete="flowComplete($flow, file_index)">

              <div class="thumbnail text-center center-block" ng-show="image.filename" style="max-width: 512px;">
                <a ng-href="{{ originPath(file_index) }}"
                  target="_blank">
                  <img ng-src="{{ thumbnailPath(file_index) }}"/>
                </a>

                <div class="caption">
                  <p>
                    <span ng-show="!isUploading(file_index) && layout_type === 'edit'"
                      class="btn btn-sm btn-primary"
                      flow-btn
                      flow-single-file
                      flow-attrs="{ accept: 'image/png, image/jpeg' }">
                      <i class="fa fa-upload"></i>
                      <strong>{{msg.btn_modify}}</strong>
                    </span>
                    <span ng-show="isUploading(file_index) && layout_type === 'edit'"
                      class="btn btn-default" disabled>
                      <i class="fa fa-refresh fa-spin"></i>
                      <span>{{ upload_info[imageKey(file_index)].upload_progress | percent }}</span>
                      <strong>{{msg.btn_uploading}}</strong>
                    </span>
                  </p>
                  <p>
                    <div class="form-control-static">
                      <textarea class="form-control" rows="1"
                        ng-model="image.comment"
                        placeholder="{{msg.comment_placeholder}}"
                        ng-disabled="layout_type === 'display'"
                        empty-to-null>
                      </textarea>
                    </div>
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row" ng-show="layout_type === 'edit' && (no_more !== 'true' || !images.length > 0)">
        <div class="col-xs-12 col-sm-4 col-md-4">
          <div flow-init
              flow-files-submitted="onUpload($flow, images.length)"
              flow-upload-started="startUpload(images.length)"
              flow-file-success="onUploaded($message, images.length)"
              flow-file-error="onFailed($message, images.length)"
              flow-progress="flowProgress($flow, images.length)"
              flow-complete="flowComplete($flow, images.length)">
            <span
              ng-show="!(isUploading(images.length))"
              class="btn btn-sm btn-success"
              flow-btn
              flow-single-file
              flow-attrs="{ accept: 'image/png, image/jpeg' }">
              <i class="fa fa-upload"></i>
              <strong>{{msg.btn_upload}}</strong>
            </span>
            <span ng-show="isUploading(images.length)"
              class="btn btn-default" disabled>
              <i class="fa fa-refresh fa-spin"></i>
              <span>{{ upload_info[imageKey(images.length)].upload_progress | percent }}</span>
              <strong>{{msg.btn_uploading}}</strong>
            </span>
            <span ng-show="getErrorMessage(images.length) !== ''">
              <p class="text-danger">
                {{getErrorMessage(images.length)}}
              </p>
            </span>
            <p style="padding-top: 5px;">
              {{msg.image_format}}
            </p>
            <p>
              {{msg.image_size}}
            </p>
          </div>
        </div>
      </div>
      """)
    return
]