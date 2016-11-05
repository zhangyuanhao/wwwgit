#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

angular.module 'ui.upload_attachment', ['ui.upload_attachment.html', 'api_internal.cfs']

.constant 'uploadAttachmentConfig', {
  'upload_title'        : ''
  'attachment'          : ''
  'attachment_format'   : ''
  'attachment_size'     : ''
  'btn_upload'          : ''
  'btn_uploading'       : ''
  'comment_placeholder' : ''
  'error_exists'        : ''
}

.controller 'UploadController', [
  '$scope'
  'FileExtension'
  ($scope, FileExtension) ->
    $scope.upload_info = {}
    $scope.msg         = {}
    $scope.faName      = FileExtension.faName

    attachmentKey = (idx) ->
      $scope.name + "_" + $scope.moduleName + "_" + $scope.moduleIndex + "_" + idx

    $scope.attachmentKey = (idx) -> attachmentKey(idx)

    # 做成上传及显示用的数据结构
    $scope.initUpload = ->
      $scope.upload_info[attachmentKey(i)] = $scope.initUploadInfo($scope.attachments[i].filename) for i in [0..$scope.attachments.length-1] if $scope.attachments?.length > 0
      $scope.upload_info[attachmentKey($scope.attachments.length)] = $scope.initUploadInfo("")

    $scope.initUploadInfo = (fileName) ->
      src             : $scope.fnSrcUrl({fName : fileName})
      uploading       : false
      upload_progress : 0
      errorMessage    : ''

    # 上传附件
    $scope.onUpload = (flow, fileIndex) ->
      index            = flow.files.length - 1
      file_ext         = flow.files[index].name.split('.').pop().toLowerCase()
      filename         = "#{$scope.name}_#{$scope.moduleName}_#{$scope.moduleIndex + 1}_#{fileIndex + 1}.#{file_ext}"
      flow.opts.target = $scope.fnUploadUrl({fName : filename})
      flow.upload()

    $scope.flowProgress = ($flow, fileIndex) ->
      $scope.upload_info[attachmentKey(fileIndex)].upload_progress = Math.min(0.99, $flow.progress())

    # 附件上传成功时的处理
    $scope.onUploaded = (resp, fileIndex) ->
      parsed_resp = JSON.parse(resp) if resp?
      # 更新显示用的数据
      updateUploadAttachment(parsed_resp, attachmentKey(fileIndex))
      # 更新attachments
      updateAttachments(parsed_resp, fileIndex)

    $scope.flowComplete = ($flow, fileIndex) ->
      $scope.upload_info[attachmentKey(fileIndex)].upload_progress = 1
      $flow.cancel()

    updateUploadAttachment = (resp, key) ->
      $scope.upload_info[key].uploading    = false
      $scope.upload_info[key].errorMessage = ''
      $scope.upload_info[key].src          = $scope.fnSrcUrl({fName : resp.name})

    updateAttachments = (resp, fileIndex) ->
      $scope.attachments[fileIndex]          = {} if !$scope.attachments[fileIndex]
      $scope.attachments[fileIndex].filename = resp.name
      $scope.attachments[fileIndex].comment  = null
      if fileIndex is ($scope.attachments.length - 1)
        $scope.upload_info[attachmentKey($scope.attachments.length)] = $scope.initUploadInfo("")

    # Attachment上传失败时的处理
    $scope.onFailed = (resp, fileIndex) ->
      $scope.upload_info[attachmentKey(fileIndex)].uploading    = false
      $scope.upload_info[attachmentKey(fileIndex)].errorMessage = JSON.parse(resp).message if resp?

    # Attachment开始上传时的处理
    $scope.startUpload = (fileIndex) ->
      $scope.upload_info[attachmentKey(fileIndex)].uploading = true

    $scope.isUploading = (fileIndex) ->
      $scope.upload_info[attachmentKey(fileIndex)]?.uploading

    $scope.getErrorMessage = (fileIndex) ->
      $scope.upload_info[attachmentKey(fileIndex)]?.errorMessage

    $scope.originPath = (fileIndex) ->
      $scope.upload_info[attachmentKey(fileIndex)]?.src

    $scope.buildFileName = (fileName, fileIndex) ->
      file_ext = fileName.split('.').pop().toLowerCase()
      "#{$scope.msg.attachment}_#{fileIndex}.#{file_ext}"

    return
  ]

.directive 'uploadAttachment', [ 'uploadAttachmentConfig', (uploadAttachmentConfig) ->
  restrict   : 'E'
  require    : '?ngModel'
  transclude : true
  scope      :
    attachments : '=ngModel'
    fnUploadUrl : '&uploadFn'
    fnSrcUrl    : '&srcFn'
  controller  : 'UploadController'
  templateUrl : 'upload_attachment.html'
  link        : (scope, element, attr, ctrl) ->
    scope.formName    = attr.formName || 'form'
    scope.title       = attr.title
    scope.name        = attr.name
    scope.moduleName  = attr.moduleName
    scope.moduleIndex = parseInt(attr.moduleIndex)
    scope.srcUrl      = attr.srcUrl
    scope.uploadUrl   = attr.uploadUrl
    scope.no_more     = attr.noMore || 'false'

    scope.msg.attachment          = uploadAttachmentConfig.attachment
    scope.msg.attachment_format   = uploadAttachmentConfig.attachment_format
    scope.msg.attachment_size     = uploadAttachmentConfig.attachment_size
    scope.msg.btn_modify          = uploadAttachmentConfig.btn_modify
    scope.msg.btn_upload          = uploadAttachmentConfig.btn_upload
    scope.msg.btn_uploading       = uploadAttachmentConfig.btn_uploading
    scope.msg.comment_placeholder = uploadAttachmentConfig.comment_placeholder
    scope.msg.error_exists        = uploadAttachmentConfig.error_exists
    scope.layout_type             = uploadAttachmentConfig.layout_type || 'edit'

    scope.initUpload()

]

angular.module 'ui.upload_attachment.html', []
.run [
  '$templateCache'
  ($templateCache) ->
    $templateCache.put(
      'upload_attachment.html',
      """
      <div class="row" ng-show="layout_type === 'edit'">
        <div class="col-xs-12 col-sm-12">
          <div class="section-header">
          <h4>{{title}}</h4>
          <div>
        </div>
      </div>
      <div ng-repeat="attachment in attachments"
        ng-init="file_index = $index">
        <div class="row">
          <div class="col-xs-12 col-sm-12 col-md-12">
            <div flow-init
                 flow-files-submitted="onUpload($flow, file_index)"
                 flow-upload-started="startUpload(file_index)"
                 flow-file-success="onUploaded($message, file_index)"
                 flow-file-error="onFailed($message, file_index)"
                 flow-progress="flowProgress($flow, file_index)"
                 flow-complete="flowComplete($flow, file_index)">

              <div ng-show="attachment.filename">
                <i class="fa fa-2x fa-fw v-a-m" ng-class="faName(attachment.filename)"></i>
                <a ng-href="{{ originPath(file_index) }}">
                  {{buildFileName(attachment.filename, file_index)}}
                </a>
                <span ng-show="!isUploading(file_index) && layout_type === 'edit'"
                  class="btn btn-sm btn-primary pull-right"
                  flow-btn
                  flow-single-file
                  flow-attrs="accept">
                  <i class="fa fa-upload"></i>
                  <strong class="hidden-xs">{{msg.btn_modify}}</strong>
                </span>
                <span ng-show="isUploading(file_index) && layout_type === 'edit'"
                  class="btn btn-default btn-sm pull-right" disabled>
                  <i class="fa fa-refresh fa-spin"></i>
                  <span>{{ upload_info[attachmentKey(file_index)].upload_progress | percent }}</span>
                  <strong class="hidden-xs">{{msg.btn_uploading}}</strong>
                </span>
                <span ng-show="getErrorMessage(file_index) !== ''">
                  <p class="text-danger">
                    {{getErrorMessage(file_index)}}
                  </p>
                </span>
              </div>
            </div>
          </div>
        </div>
        <div class="row" ng-show="attachment.filename">
          <div class="col-xs-12 col-sm-12">
            <div class="form-control-static">
              <textarea class="form-control" rows="1"
                ng-model="attachment.comment"
                placeholder="{{msg.comment_placeholder}}"
                ng-disabled="layout_type === 'display'"
                empty-to-null>
              </textarea>
            </div>
          </div>
        </div>
      </div>

      <div class="row" ng-show="layout_type === 'edit' && (no_more !== 'true' || !attachments.length > 0)">
        <div class="col-xs-12">
          <div flow-init
               flow-files-submitted="onUpload($flow, attachments.length)"
               flow-upload-started="startUpload(attachments.length)"
               flow-file-success="onUploaded($message, attachments.length)"
               flow-file-error="onFailed($message, attachments.length)"
               flow-progress="flowProgress($flow, attachments.length)"
               flow-complete="flowComplete($flow, attachments.length)">
            <span
              ng-show="!(isUploading(attachments.length))"
              class="btn btn-success btn-sm"
              flow-btn
              flow-single-file>
              <i class="fa fa-upload"></i>
              <strong>{{msg.btn_upload}}</strong>
            </span>
            <span ng-show="isUploading(attachments.length)"
              class="btn btn-default btn-sm" disabled>
              <i class="fa fa-refresh fa-spin"></i>
              <span>{{ upload_info[attachmentKey(attachments.length)].upload_progress | percent }}</span>
              <strong>{{msg.btn_uploading}}</strong>
            </span>
            <span ng-show="getErrorMessage(attachments.length) !== ''">
              <p class="text-danger">
                {{getErrorMessage(attachments.length)}}
              </p>
            </span>
            <p style="padding-top: 5px;">
              {{msg.attachment_format}}
            </p>
            <p>
              {{msg.attachment_size}}
            </p>
          </div>
        </div>
      </div>
      """)
    return
]