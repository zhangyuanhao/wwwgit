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
this.views.infogathering ?= {}

views.infogathering.show = angular.module 'infogathering.show', [
  'ui.bootstrap'
  'ui.parts'
  'ui.upload_image'
  'ui.common'
  'ui.address'
  'api.helper'
  'api_internal.institution'
  'flow'
]

.factory 'InfoGatheringSvc', [
  'Alert'
  'ClientError'
  '$http'
  '$filter'
  'AddressCheck'
  (Alert, ClientError, $http, $filter, AddressCheck) ->
    service                     = {}
    service.dictionary          = {}
    service.jsRoutes            = jsRoutes
    service.authorization_saved = false

    service.load = (id, token) ->
      $http.get(
        "/api_internal/infogathering/#{id}/blank"
        headers : service.http_headers
        ).then (resp) ->
          service.blank = resp.data
          loadInfogathering(id)

    loadInfogathering = (id)->
      $http.get(
        "/api_internal/infogathering/#{id}"
        headers : service.http_headers
        ).then (resp) ->
          service.value = resp.data
          if service.value.authorization then service.authorization_saved = true
          initInfogatheringInfo()

    initInfogatheringInfo = ->
      blank = service.blank.sections
      service.value.professional_licenses = initItemValue('professional_licenses') if blank.professional_licenses? and service.value.professional_licenses is undefined
      service.value.education             = initItemValue('education') if blank.education? and service.value.education is undefined
      service.value.employment            = initItemValue('employment') if blank.employment? and service.value.employment is undefined

    initItemValue = (key)->
      list    : []
      no_more : false
      range   : service.blank.sections[key].range

    service.newDatepicker = ->
      date_options :
        maxDate : new Date()
      opened : false
      open   : -> this.opened = true

    service.newEarning = (data) ->
      earning = {}
      if data?
        earning.type = "salary"
        earning.data =
          rate :
            amount   : data
            currency : "CNY"
          period : "Annual"
      earning

    service.getUploadUrl = (file_name) ->
      "#{jsRoutes.controllers.InfoGatheringCtrl.uploadImage(file_name).url}"

    service.getLoadUrl = (file_name) ->
      "#{jsRoutes.controllers.InfoGatheringCtrl.image(file_name).url}&form_id=#{@form_id}&access_token=#{@access_token}"

    service.getThumbnailloadUrl = (file_name) ->
      "#{jsRoutes.controllers.InfoGatheringCtrl.image(file_name, 512).url}&form_id=#{@form_id}&access_token=#{@access_token}"

    # 身份信息保存
    service.identitySave = (data, callback)->
      info = identity : data
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          ->
            service.value.identity = data
            callback()
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    # 授权信息保存
    service.authorizationSave = (data, callback) ->
      info = authorization : data
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          ->
            service.value.authorization = data
            service.authorization_saved = true
            callback()
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    # 学历信息保存
    service.educationSave = (data, idx, callback)->
      edu = angular.copy(@value.education)
      if edu.list[idx]?
        edu.list[idx] = data
      else
        edu.list.push data
      info = education : edu
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          ->
            service.value.education = edu
            callback()
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    service.noMoreEducation = ->
      info = education : @value.education
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          => console.log @value.education.no_more
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    # 学历信息删除
    service.educationDelete = (idx)->
      @value.education.list.splice idx, 1
      info = education : @value.education
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          -> console.log 'delete'
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    # 专业资格信息保存
    service.prlSave = (data, callback)->
      prl = angular.copy(@value.professional_licenses)
      if prl.list[0]?
        prl.list[0] = data
      else
        prl.list.push data
      info = professional_licenses : prl
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          ->
            service.value.professional_licenses = prl
            callback()
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    service.noMorePrl = ->
      info = professional_licenses : @value.professional_licenses
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          => console.log @value.professional_licenses.no_more
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    # 履历信息保存
    service.employmentSave = (data, idx, callback)->
      employ = angular.copy(@value.employment)
      if employ.list[idx]?
        employ.list[idx] = data
      else
        employ.list.push data
      info = employment : employ
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          ->
            service.value.employment = employ
            callback()
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    service.noMoreEmployment = ->
      info = employment : @value.employment
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          => console.log @value.employment.no_more
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    # 履历信息删除
    service.employmentDelete = (idx)->
      @value.employment.list.splice idx, 1
      info = employment : @value.employment
      $http.post(
        "/api_internal/infogathering/#{@form_id}"
        info
        headers : @http_headers
        ).then(
          -> console.log 'delete'
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    # 提交
    service.submit = ->
      info = info : {}
      $http.post(
        "/api_internal/infogathering/#{@form_id}/submit"
        info
        headers : @http_headers
        ).then(
          -> Alert.success service.dictionary['msg.submitted']
          (resp) -> Alert.danger ClientError.messages(resp)
        )

    return service
]

.controller 'InfoGatheringCtrl', [
  '$scope'
  '$http'
  '$timeout'
  '$window'
  '$filter'
  'Alert'
  'InfoGatheringSvc'
  'Institution'
  'AddressCheck'
  ($scope, $http, $timeout, $window, $filter, Alert, InfoGatheringSvc, Institution, AddressCheck) ->
    $scope.Svc                    = InfoGatheringSvc
    $scope.identity_display       = "blank.html"
    $scope.prl_display            = "blank.html"
    $scope.new_education_display  = "blank.html"
    $scope.new_employment_display = "blank.html"
    $scope.authorization_display  = "blank.html"
    $scope.signatureWidth         = 0
    $scope.signatureHeight        = 0
    $scope.date_picker            =
      birth_date          : InfoGatheringSvc.newDatepicker()
      issue_date          : InfoGatheringSvc.newDatepicker()
      expire_date         : InfoGatheringSvc.newDatepicker()
      edu_start_date      : InfoGatheringSvc.newDatepicker()
      edu_graduation_date : InfoGatheringSvc.newDatepicker()
      awarded_date        : InfoGatheringSvc.newDatepicker()
      employ_start_date   : InfoGatheringSvc.newDatepicker()
      employ_end_date     : InfoGatheringSvc.newDatepicker()
      employ_end_date_1   : InfoGatheringSvc.newDatepicker()
      no_check_until      : InfoGatheringSvc.newDatepicker()
    $scope.date_picker.expire_date.date_options.maxDate              = null
    $scope.date_picker.employ_start_date.date_options.datepickerMode = 'month'
    $scope.date_picker.employ_start_date.date_options.minMode        = 'month'
    $scope.date_picker.employ_end_date.date_options.datepickerMode   = 'month'
    $scope.date_picker.employ_end_date.date_options.minMode          = 'month'
    $scope.date_picker.employ_end_date_1.date_options.maxDate        = null
    $scope.date_picker.employ_end_date_1.date_options.datepickerMode = 'month'
    $scope.date_picker.employ_end_date_1.date_options.minMode        = 'month'
    $scope.date_picker.no_check_until.date_options.maxDate           = null
    $scope.date_picker.no_check_until.date_options.minDate           = new Date()

    displayUrl = (key)->
      "/infogathering/parts?sub=#{key}&form_id=#{InfoGatheringSvc.form_id}&access_token=#{InfoGatheringSvc.access_token}"

    initEducationsDisplay = ->
      $scope.educations_display = []
      for i in [0..1]
        $scope.educations_display.push "blank.html"

    initEmploymentsDisplay = ->
      $scope.employments_display = []
      for i in [0..30]
        $scope.employments_display.push "blank.html"

    initEducationsDisplay()
    initEmploymentsDisplay()

    $scope.newIdentity = ->
      $scope.identity_display = displayUrl('identity')
      $scope.identity_data    = angular.copy InfoGatheringSvc.blank.sections.identity
      initIdentityInfo()
      if $scope.Svc.value.authorization
        $scope.identity_data.basic_info.id_doc_nbr.type =
          angular.copy $scope.Svc.value.authorization.handwritten.inputs.identity.type
        $scope.identity_data.basic_info.id_doc_nbr.number =
          angular.copy $scope.Svc.value.authorization.handwritten.inputs.identity.number

    $scope.editIdentity = ->
      $scope.identity_display = displayUrl('identity')
      $scope.identity_data    = angular.copy InfoGatheringSvc.value.identity

    $scope.cancelIdentity = ->
      $scope.identity_display = 'blank.html'
      $scope.identity_data    = {}

    $scope.saveIdentity = ->
      InfoGatheringSvc.identitySave($scope.identity_data, $scope.cancelIdentity)

    $scope.newPrl = ->
      $scope.prl_display = displayUrl('prl')
      $scope.prl_data    = angular.copy InfoGatheringSvc.blank.sections.professional_licenses.list[0]

    $scope.editPrl = ->
      $scope.prl_display = displayUrl('prl')
      $scope.prl_data    = angular.copy InfoGatheringSvc.value.professional_licenses.list[0]

    $scope.cancelPrl = ->
      $scope.prl_display = 'blank.html'
      $scope.prl_data    = {}

    $scope.savePrl = ->
      InfoGatheringSvc.prlSave($scope.prl_data, $scope.cancelPrl)

    $scope.noMorePrl = ->
      $scope.cancelPrl()
      InfoGatheringSvc.noMorePrl()

    # 学历信息
    initEducationInfo = ->
      $scope.education_info =
        address_invalid : false

    $scope.newEducation = (idx)->
      $scope.new_education_display = displayUrl('education')
      initEducationsDisplay()
      $scope.education_data        = angular.copy InfoGatheringSvc.blank.sections.education.list[idx]
      $scope.education_idx         = idx
      initEducationInfo()

    $scope.editEducation = (idx)->
      $scope.new_education_display   = 'blank.html'
      initEducationsDisplay()
      $scope.educations_display[idx] = displayUrl('education')
      $scope.education_data          = angular.copy InfoGatheringSvc.value.education.list[idx]
      $scope.education_idx           = idx
      initEducationInfo()

    $scope.cancelEducation = ->
      $scope.new_education_display = 'blank.html'
      initEducationsDisplay()
      $scope.education_data        = {}
      $scope.education_idx         = null
      $scope.education_info        = {}

    $scope.initDegree = ->
      if !$scope.education_data.degree
        $scope.education_data.degree =
          date_of_award : "1900-01-01"
          institution   : null
          major         : null
          degree_type   : null
          degree_images : []

    $scope.saveEducation = ->
      if AddressCheck.addressValidator($scope.education_data.education_details.address, true)
        edu = $scope.education_data
        if edu.education_details.degree_awarded and edu.degree?
          edu.degree.institution   = $scope.education_data.education_details.institution
          edu.degree.major         = $scope.education_data.education_details.major
        else
          edu.degree = null
        InfoGatheringSvc.educationSave(edu, $scope.education_idx, $scope.cancelEducation)
      else
        $scope.education_info.address_invalid = true

    $scope.noMoreEducation = ->
      InfoGatheringSvc.noMoreEducation()
      $scope.new_education_display = 'blank.html'

    # 工作履历信息
    initEmploymentInfo = ->
      $scope.employment_info =
        address_invalid : false
      employ   = $scope.employment_data
      if !_.isEmpty employ.fields.earnings
        $scope.employment_info.earning = employ.fields.earnings[0].data.rate.amount/10000

    $scope.newEmployment = (idx)->
      $scope.new_employment_display = displayUrl('employment')
      initEmploymentsDisplay()
      $scope.employment_idx         = idx
      getLastBlank(idx)
      initEmploymentInfo()

    getLastBlank = (idx)->
      employs = InfoGatheringSvc.blank.sections.employment.list
      if employs[idx]?
        $scope.employment_data = employs[idx]
      else
        $scope.employment_data = angular.copy(_.last employs)
      if idx is 0
        $scope.employment_data.fields.still_employed = null

    $scope.editEmployment = (idx)->
      $scope.new_employment_display   = 'blank.html'
      initEmploymentsDisplay()
      $scope.employments_display[idx] = displayUrl('employment')
      $scope.employment_data          = angular.copy InfoGatheringSvc.value.employment.list[idx]
      $scope.employment_idx           = idx
      initEmploymentInfo()

    $scope.cancelEmployment = ->
      $scope.new_employment_display = 'blank.html'
      initEmploymentsDisplay()
      $scope.employment_data        = {}
      $scope.employment_idx         = null
      $scope.employment_info        = {}

    $scope.saveEmployment = ->
      if AddressCheck.addressValidator($scope.employment_data.fields.address, true)
        employ                 = $scope.employment_data
        earning                = newEarning($scope.employment_info.earning)
        employ.fields.earnings = []
        if !_.isEmpty earning
          employ.fields.earnings.push earning
        employ.fields.no_check_until = null if !employ.fields.still_employed
        InfoGatheringSvc.employmentSave(employ, $scope.employment_idx, $scope.cancelEmployment)
      else
        $scope.employment_info.address_invalid = true

    newEarning = (data) ->
      earning = {}
      if data?
        earning.type = "salary"
        earning.data =
          rate :
            amount   : data * 10000
            currency : "CNY"
          period : "Annual"
      earning

    $scope.noMoreEmployment = ->
      InfoGatheringSvc.noMoreEmployment()
      $scope.new_employment_display = 'blank.html'

    $scope.getInstitutions = (val) ->
      $http.get(
        "/api_internal/infogathering/institutions?page=1&per_page=1000&q=(name:#{val}*)"
        headers : InfoGatheringSvc.http_headers
        ).then (resp) ->
          resp.data

    $scope.onWindowResize = ->
      if $scope.signatureWidth isnt $scope.signatureCanvas_en.offsetWidth
        $scope.signaturePad_en.clear()
        $scope.signaturePad_zh.clear()
        $scope.signatureWidth            = $scope.signatureCanvas_en.offsetWidth
        $scope.signatureHeight           = $scope.signatureCanvas_en.offsetHeight
        ratio                            = Math.max($window.devicePixelRatio || 1, 1)
        $scope.signatureCanvas_en.width  = $scope.signatureCanvas_en.offsetWidth * ratio
        $scope.signatureCanvas_en.height = $scope.signatureCanvas_en.offsetHeight * ratio
        $scope.signatureCanvas_en.getContext("2d").scale(ratio, ratio)
        $scope.signatureCanvas_zh.width  = $scope.signatureCanvas_en.offsetWidth * ratio
        $scope.signatureCanvas_zh.height = $scope.signatureCanvas_en.offsetHeight * ratio
        $scope.signatureCanvas_zh.getContext("2d").scale(ratio, ratio)

    $scope.newAuthorization = ->
      if $scope.Svc.blank.sections.authorization and !$scope.Svc.authorization_saved
        $scope.authorization_display = displayUrl('authorization')
        $scope.authorization_data    = angular.copy InfoGatheringSvc.blank.sections.authorization
        $scope.authorization_data.handwritten.inputs.identity        = {}
        $scope.authorization_data.handwritten.inputs.identity.type   = 'cn.id_card_number'
        $scope.authorization_data.handwritten.inputs.identity.number = null
        $scope.signatureWidth = 0
        $timeout $scope.initSignature, 300

    $scope.initSignature = ->
      $scope.signatureCanvas_en = document.getElementById('signature_pad_en')
      $scope.signaturePad_en    = new SignaturePad($scope.signatureCanvas_en)
      $scope.signatureCanvas_zh = document.getElementById('signature_pad_zh')
      $scope.signaturePad_zh    = new SignaturePad($scope.signatureCanvas_zh)
      angular.element($window).bind('resize', $scope.onWindowResize)
      $scope.onWindowResize()

    $scope.resizeSignature = (image, newHeight) ->
      canvas        = document.createElement('canvas')
      ctx           = canvas.getContext('2d')
      canvas.height = newHeight
      canvas.width  = $scope.signatureWidth * newHeight / $scope.signatureHeight
      ctx.drawImage(image, 0, 0, canvas.width, canvas.height)
      canvas.toDataURL()

    $scope.saveAuthorization = ->
      if !$scope.signaturePad_en.isEmpty() and !$scope.signaturePad_zh.isEmpty()
        $scope.authorization_data.handwritten.inputs.signature_en = null
        $scope.authorization_data.handwritten.inputs.signature_zh = null
        img_en     = new Image
        img_en.src = $scope.signaturePad_en.toDataURL()
        img_en.onload = ->
          $scope.authorization_data.handwritten.inputs.signature_en =
            $scope.resizeSignature(img_en, 64)
          saveAuthorization($scope.authorization_data.handwritten.inputs.signature_zh)

        img_zh     = new Image
        img_zh.src = $scope.signaturePad_zh.toDataURL()
        img_zh.onload = ->
          $scope.authorization_data.handwritten.inputs.signature_zh =
            $scope.resizeSignature(img_zh, 64)
          saveAuthorization($scope.authorization_data.handwritten.inputs.signature_en)
      else Alert.danger $scope.Svc.dictionary['msg.signature.empty']

    saveAuthorization = (url) ->
      if url isnt null
        $scope.authorization_data.handwritten.inputs.signed_on =
          $filter('date')(new Date(), 'yyyy-MM-dd')
        InfoGatheringSvc.authorizationSave($scope.authorization_data, $scope.cancelAuthorization)

    $scope.editAuthorization = ->
      $scope.authorization_display = displayUrl('authorization')
      $scope.authorization_data    = angular.copy InfoGatheringSvc.value.authorization
      if !$scope.authorization_data.handwritten.inputs.identity
        $scope.authorization_data.handwritten.inputs.identity.type   = 'cn.id_card_number'
        $scope.authorization_data.handwritten.inputs.identity.number = null
      $scope.signatureWidth  = 0
      $scope.signatureHeight = 0
      $timeout $scope.initSignature, 300

    $scope.cancelAuthorization = ->
      $scope.authorization_display = 'blank.html'


    $scope.Svc.load($scope.Svc.form_id, $scope.Svc.access_token)
      .then $scope.newAuthorization

    return
]

angular.module('app').requires.push 'infogathering.show'