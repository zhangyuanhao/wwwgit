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

views.tasks.task_svc = angular.module 'tasks.task_svc', [
  'ui.parts'
  'ui.upload_attachment'
  'api.helper'
  'ui.address'
  'api_internal.employee_orders'
  'api_internal.task'
  'api_internal.message'
]

.factory 'TaskSvc', [
  '$filter'
  'Alert'
  'EmployeeOrder'
  'Task'
  'Message'
  ($filter, Alert, EmployeeOrder, Task, Message) ->
    service                       = {}
    service.dictionary            = {}
    service.dictionary.reason_def = {}
    service.task_id               = null
    service.order_id              = null
    service.last_comment          = null
    service.task_comment          = null
    service.layout_type           = ''
    service.mistakes              = []
    service.audio_info            = []
    service.jsRoutes              = jsRoutes
    service.infogathering         = {}
    service.task_info             =
      identity   : is_collapsed : true
      education0 : is_collapsed : true
      education1 : is_collapsed : true
      criminal   : is_collapsed : true
      ill        : is_collapsed : true
      court      : is_collapsed : true
      fir        : is_collapsed : true
      cbi        : is_collapsed : true
      prl        : is_collapsed : true
      employment : []
    service.opinionMessages       = []

    service.newDatepicker = (max = true, mode = "day")->
      ret =
        date_options :
          datepickerMode : mode
          minMode        : mode
        opened : false
        open   : -> this.opened = true
      ret.date_options.maxDate = new Date() if max
      ret

    service.date_picker =
      identity   :
        birth_date_zh : service.newDatepicker()
        birth_date_en : service.newDatepicker()
      education0 :
        start_date_zh        : service.newDatepicker(true, "month")
        start_date_en        : service.newDatepicker(true, "month")
        end_date_zh          : service.newDatepicker(true, "month")
        end_date_en          : service.newDatepicker(true, "month")
        degree_award_date_zh : service.newDatepicker()
        degree_award_date_en : service.newDatepicker()
      education1 :
        start_date_zh        : service.newDatepicker(true, "month")
        start_date_en        : service.newDatepicker(true, "month")
        end_date_zh          : service.newDatepicker(true, "month")
        end_date_en          : service.newDatepicker(true, "month")
        degree_award_date_zh : service.newDatepicker()
        degree_award_date_en : service.newDatepicker()
      prl :
        issue_date_zh        : service.newDatepicker()
        issue_date_en        : service.newDatepicker()
      employment : []

    newEarning =  ->
      type : "salary"
      data :
        rate :
          amount   : null
          currency : "CNY"
        period : "Annual"

    service.loadTask = (task_id)->
      Task.get(
        id : task_id
      ).$promise.then (task) ->
        service.task = task
        loadEmploymentCollapse(task)
        service.buildUploadAudioInfo(service.task)
        initIdentity()
        initEducation()
        initPrl()
        initCriminal()
        initIll()
        initCourt()
        initFir()
        initCbi()
        initEmployment()
        performanceMessages()
        task.order_id

    initFacts = ->
      fact =
        primary :
          fact   : []
          source : ""
        others : []
      origin     : angular.copy fact
      translated :
        zh : angular.copy fact
        en : angular.copy fact

    initProvided = (field)->
      if field.provided? and field.provided.translated is null
        field.provided.translated =
          zh : angular.copy field.provided.origin
          en : angular.copy field.provided.origin

    initIdentity = ->
      if service.task.content.identity?
        initProvided(service.task.content.identity.checks.basic_info)

    initEducation = ->
      if service.task.content.education?
        for education in service.task.content.education.list
          initProvided(edu) for edu in _.values education.education_details.checks if education.education_details?
          initProvided(degree) for degree in _.values education.degree.checks if education.degree?

    initPrl = ->
      if service.task.content.professional_licenses?
        for prl in service.task.content.professional_licenses.list
          initProvided(field) for field in _.values prl.checks

    initEmployment = ->
      if service.task.content.employment?
        for employment in service.task.content.employment.list
          for interview in _.values employment.interviews
            initProvided(field) for field in _.values interview.employment_details.checks

    initCriminal = ->
      criminal = service.task.content.criminal_records
      criminal.checks.records.facts = initFacts() if criminal? and criminal.checks.records.facts is null

    initIll = ->
      ill = service.task.content.illegal_organization_records
      ill.checks.records.facts = initFacts() if ill? and ill.checks.records.facts is null

    initCourt = ->
      court = service.task.content.court_records
      court.checks.records.facts = initFacts() if court? and court.checks.records.facts is null

    initFir = ->
      fir = service.task.content.financial_irregularities
      fir.checks.csrc_ap.facts = initFacts() if fir? and fir.checks.csrc_ap.facts is null
      fir.checks.csrc_smb.facts = initFacts() if fir? and fir.checks.csrc_smb.facts is null
      fir.checks.circ_ap.facts = initFacts() if fir? and fir.checks.circ_ap.facts is null

    initCbi = ->
      cbi = service.task.content.conflict_of_business_interest
      cbi.checks.legal_representative.facts = initFacts() if cbi? and cbi.checks.legal_representative.facts is null
      cbi.checks.corporate_executive.facts = initFacts() if cbi? and cbi.checks.corporate_executive.facts is null
      cbi.checks.shareholder.facts = initFacts() if cbi? and cbi.checks.shareholder.facts is null

    loadEmploymentCollapse = (task) ->
      employmentList = task.content.employment?.list
      _.map employmentList, (employment) ->
        _.mapObject employment.interviews, (val, key) ->
          employmentIndex = _.indexOf(employmentList, employment)
          service.task_info.employment[employmentIndex] = {} if service.task_info.employment[employmentIndex] is undefined
          service.task_info.employment[employmentIndex][key] = {} if service.task_info.employment[employmentIndex][key] is undefined
          service.task_info.employment[employmentIndex][key + "_Copy"] = {} if service.task_info.employment[employmentIndex][key + "_Copy"] is undefined
          service.task_info.employment[employmentIndex][key].is_collapsed = true
          service.task_info.employment[employmentIndex][key + "_Copy"].is_collapsed = true

          service.date_picker.employment[employmentIndex] = {} if service.date_picker.employment[employmentIndex] is undefined
          service.date_picker.employment[employmentIndex][key] =
            start_date_zh : service.newDatepicker(true, "month")
            start_date_en : service.newDatepicker(true, "month")
            end_date_zh   : service.newDatepicker(false, "month")
            end_date_en   : service.newDatepicker(false, "month")
          service.date_picker.employment[employmentIndex][key + "_Copy"] =
            start_date_zh : service.newDatepicker(true, "month")
            start_date_en : service.newDatepicker(true, "month")
            end_date_zh   : service.newDatepicker(false, "month")
            end_date_en   : service.newDatepicker(false, "month")

    # 根据audio_files做成画面播放以及显示内容的数据结构
    service.buildUploadAudioInfo = (task) ->
      employmentList = task.content.employment?.list
      _.map employmentList, (employment) ->
        _.mapObject employment.interviews, (val, key) ->
          employmentIndex = _.indexOf(employmentList, employment)
          audio_files = val.audio_files
          service.audio_info["#{employmentIndex}_#{key}_#{i}"] = service.initAudioInfo(audio_files[i].filename) for i in [0..audio_files.length-1] if audio_files?.length
          service.audio_info["#{employmentIndex}_#{key}_#{val.audio_files.length}"] = service.initAudioInfo("")

    service.initAudioInfo = (source_name) ->
      # src路径
      src : "#{jsRoutes.controllers.EmployeeOrdersCtrl.streamAudio(service.order_id, source_name).url}"
      # 是否正在上传文件
      uploading : false
      upload_progress : 0
      # 错误信息
      errorMessage: ''

    service.getUploadUrl = (file_name) ->
      "#{jsRoutes.controllers.EmployeeOrdersCtrl.uploadAttachment(@order_id, @task_id, file_name).url}"

    service.getLoadUrl = (file_name) ->
      "#{jsRoutes.controllers.EmployeeOrdersCtrl.attachment(@order_id, file_name).url}"

    service.isAudioUploading = (reference_type, employment_index, audio_index) ->
      key = "#{employment_index}_#{reference_type}_#{audio_index}"
      service.audio_info[key]?.uploading

    service.audioSrc = (reference_type, employment_index, audio_index) ->
      key = "#{employment_index}_#{reference_type}_#{audio_index}"
      service.audio_info[key]?.src

    loadLang = (language, langs) ->
      return true if language is langs.lang
      for l in langs.other_langs
        return true if language is l
      false

    service.loadOrder = (order_id)->
      EmployeeOrder.get(
        id : order_id
      ).$promise.then (order) ->
        service.order = order
        service.lang = {}
        service.lang.zh = loadLang("zh", order.content.additional_terms)
        service.lang.en = loadLang("en", order.content.additional_terms)

    # 取得信息收集表内容
    service.loadInfogathering = ->
      EmployeeOrder.infogathering(
        id : service.order.id
        section : 'authorization'
      ).$promise.then (authorization) ->
        service.infogathering.authorization = authorization

      EmployeeOrder.infogathering(
        id : service.order.id
        section : 'identity'
      ).$promise.then (identity) ->
        service.infogathering.identity = identity

      Alert.danger fault.data.message

    # 工作表现问题选项相关
    performanceMessages = ->
      employment = service.task.content.employment
      if employment?
        _.map employment.list, (employ, idx) ->
          service.opinionMessages[idx] = {}
          _.mapObject employ.interviews, (i_val, i_key) ->
            service.opinionMessages[idx][i_key] = {}
            if i_val.work_performance?
              _.mapObject i_val.work_performance.checks, (p_val, p_key) ->
                service.opinionMessages[idx][i_key][p_key] = {}
                message_key = p_key
                if p_key.indexOf("_Copy") > -1
                  message_key = p_key.replace('_Copy', '')
                if p_val.opinions? and p_val.opinions.length > 0
                  Message.get(
                    prefix : message_key
                    keys   : p_val.opinions.join(',')
                  ).$promise.then (msg) =>
                    service.opinionMessages[idx][i_key][p_key] = msg

    service.questionMessage = (idx, referenceType, key, opinion) ->
      @opinionMessages[idx][referenceType][key][key + '.' + opinion]

    service.answerMessage = (idx, referenceType, key, answer) ->
      @opinionMessages[idx][referenceType][key][key + '.' + answer]

    service.judgementNullCheck = (judgement) ->
      if !judgement
        ''
      else
        judgement

    service.getAnswers = (question, opinions) ->
      key = question.replace('.0', '.')
      _.filter opinions, (opinion) ->
        opinion.indexOf(key) isnt -1 and opinion isnt question

    service.toJodaJsonDate = (date, need_default = true) ->
      if date?
        $filter('date')(date, 'yyyy-MM-dd')
      else if need_default
        '1900-01-01'
      else
        ""

    service.copyInstitution = (idx, language)->
      edu = service.task.content.education.list[idx]
      institution = edu.education_details.checks.institution.provided.translated[language]
      edu.institution.translated[language] = institution

    service.criminalAdd = (record, language)->
      records = @task.content.criminal_records.checks.records.facts.translated[language].primary.fact
      records.push angular.copy(record)

    service.criminalRemove = (idx, language)->
      records = @task.content.criminal_records.checks.records.facts.translated[language].primary.fact
      records.splice(idx,1)

    service.illAdd = (record, language)->
      records = @task.content.illegal_organization_records.checks.records.facts.translated[language].primary.fact
      records.push angular.copy(record)

    service.illRemove = (idx, language)->
      records = @task.content.illegal_organization_records.checks.records.facts.translated[language].primary.fact
      records.splice(idx,1)

    service.courtAdd = (record, language)->
      records = @task.content.court_records.checks.records.facts.translated[language].primary.fact
      records.push angular.copy(record)

    service.courtRemove = (idx, language)->
      records = @task.content.court_records.checks.records.facts.translated[language].primary.fact
      records.splice(idx,1)

    service.firAdd = (record, fir_type, language)->
      records = @task.content.financial_irregularities.checks[fir_type].facts.translated[language].primary.fact
      records.push angular.copy(record)

    service.firRemove = (fir_type, idx, language)->
      records = @task.content.financial_irregularities.checks[fir_type].facts.translated[language].primary.fact
      records.splice(idx,1)

    service.cbiAdd = (record, cbi_type, language)->
      records = @task.content.conflict_of_business_interest.checks[cbi_type].facts.translated[language].primary.fact
      records.push angular.copy(record)

    service.cbiRemove = (cbi_type, idx, language)->
      records = @task.content.conflict_of_business_interest.checks[cbi_type].facts.translated[language].primary.fact
      records.splice(idx,1)

    service.save = ->
      Task.save(
        id : @task.id,
        @task.content,
        =>
          Alert.success @dictionary.msg['msg.saved']
        (resp) =>
          Alert.danger resp.data.message
      )
    service
]

.controller 'CriminalCtrl', [
  '$scope'
  'TaskSvc'
  ($scope, TaskSvc) ->
    $scope.TaskSvc    = TaskSvc
    $scope.input_page = "blank.html"
    $scope.criminal_info =
      imprisoned_on_picker           : TaskSvc.newDatepicker(true)
      released_from_prison_on_picker : TaskSvc.newDatepicker(true)

    initCriminal = ->
      classification          : null
      offense                 : null
      imprisoned_on           : null
      authority               : null
      sentence_length         : null
      result_of_justice       : null
      released_from_prison_on : null
      reason_for_releasing    : null
      case_summary            : null
      comment                 : null

    $scope.newCriminal = (language)->
      $scope.criminal = initCriminal()
      switch language
        when 'zh'   then $scope.input_page = "criminalInputZh.html"
        when 'en'   then $scope.input_page = "criminalInputEn.html"

    $scope.cancelCriminal = ->
      $scope.input_page = "blank.html"

    $scope.addCriminal = (language)->
      TaskSvc.criminalAdd($scope.criminal, language)
      $scope.input_page = "blank.html"

    return
]

.controller 'IllCtrl', [
  '$scope'
  'TaskSvc'
  ($scope, TaskSvc) ->
    $scope.TaskSvc    = TaskSvc
    $scope.input_page = "blank.html"

    initIll = ->
      search : "PRCIOR"
      result : null

    $scope.newIll = (language)->
      $scope.ill = initIll()
      switch language
        when 'zh'   then $scope.input_page = "illInputZh.html"
        when 'en'   then $scope.input_page = "illInputEn.html"

    $scope.cancelIll = ->
      $scope.input_page = "blank.html"

    $scope.addIll = (language)->
      TaskSvc.illAdd($scope.ill, language)
      $scope.input_page = "blank.html"

    return
]

.controller 'CourtCtrl', [
  '$scope'
  'TaskSvc'
  ($scope, TaskSvc) ->
    $scope.TaskSvc    = TaskSvc
    $scope.input_page = "blank.html"
    $scope.court_info = court_date_picker : TaskSvc.newDatepicker()

    initCourt = ->
      classification   : null
      court_date       : null
      court            : null
      party            : null
      disposition      : null
      comment          : null
      sentence         : null
      case_number      : null
      file_date        : null
      disposition_date : null
      defendant        : null
      plaintiff        : null
      sentence_date    : null

    $scope.newCourt = (language)->
      $scope.court = initCourt()
      switch language
        when 'zh'   then $scope.input_page = "courtInputZh.html"
        when 'en'   then $scope.input_page = "courtInputEn.html"

    $scope.cancelCourt = ->
      $scope.input_page = "blank.html"

    $scope.addCourt = (language)->
      TaskSvc.courtAdd($scope.court, language)
      $scope.input_page = "blank.html"

    return
]

.controller 'FIRCtrl', [
  '$scope'
  'TaskSvc'
  ($scope, TaskSvc) ->
    $scope.TaskSvc    = TaskSvc
    $scope.input_page =
      csrc_ap  : "blank.html"
      csrc_smb : "blank.html"
      circ_ap  : "blank.html"
    $scope.fir_info = issue_date_picker : TaskSvc.newDatepicker()

    initFir = ->
      comment        : null
      number         : null
      issue_date     : null
      classification : null
      title          : null
      index          : null
      authority      : null
      url            : null

    $scope.newFir = (fir_type, language)->
      $scope.fir = initFir()
      switch fir_type
        when 'csrc_ap'
          $scope.input_page.csrc_ap = "firCSRCAPInputZh.html" if language is "zh"
          $scope.input_page.csrc_ap = "firCSRCAPInputEn.html" if language is "en"
        when 'csrc_smb'
          $scope.input_page.csrc_smb = "firCSRCSMBInputZh.html" if language is "zh"
          $scope.input_page.csrc_smb = "firCSRCSMBInputEn.html" if language is "en"
        when 'circ_ap'
          $scope.input_page.circ_ap = "firCIRCAPInputZh.html" if language is "zh"
          $scope.input_page.circ_ap = "firCIRCAPInputEn.html" if language is "en"

    $scope.cancelFir = (fir_type)->
      $scope.input_page[fir_type] = "blank.html"

    $scope.addFir = (fir_type, language)->
      TaskSvc.firAdd($scope.fir, fir_type, language)
      $scope.input_page[fir_type] = "blank.html"

    return
]

.controller 'CBICtrl', [
  '$scope'
  '$filter'
  'TaskSvc'
  ($scope, $filter, TaskSvc) ->
    $scope.TaskSvc    = TaskSvc
    $scope.input_page =
      legal_representative : "blank.html"
      shareholder          : "blank.html"
      corporate_executive  : "blank.html"

    initCbi = ->
      name                  : null
      corporation           :
        name                : null
        registration_number : null
        business_type       : null
        registered_capital  :
          amount   : null
          currency : "CNY"
        status              : null
      comment               : null
      code_number           : self : ""
      investment            :
        amount   : null
        currency : "CNY"
      investment_ratio      : null
      position_title        :
        job_title  : null
        department : null

    $scope.newCbi = (cbi_type, language)->
      $scope.cbi = initCbi()
      switch cbi_type
        when 'legal_representative'
          $scope.input_page.legal_representative = "cbiLRInputZh.html" if language is "zh"
          $scope.input_page.legal_representative = "cbiLRInputEn.html" if language is "en"
        when 'shareholder'
          $scope.input_page.shareholder = "cbiSInputZh.html" if language is "zh"
          $scope.input_page.shareholder = "cbiSInputEn.html" if language is "en"
        when 'corporate_executive'
          $scope.input_page.corporate_executive = "cbiCEInputZh.html" if language is "zh"
          $scope.input_page.corporate_executive = "cbiCEInputEn.html" if language is "en"

    $scope.cancelCbi = (cbi_type)->
      $scope.input_page[cbi_type] = "blank.html"

    $scope.addCbi = (cbi_type, language)->
      candidate_name = $filter('personalName')(TaskSvc.order.candidate_info.personal_name, TaskSvc.language)
      $scope.cbi.name = candidate_name
      rc = $scope.cbi.corporation.registered_capital
      if rc.amount?
        $scope.cbi.corporation.registered_capital.amount = Math.round10(rc.amount * 10000)
      else
        $scope.cbi.corporation.registered_capital = null
      investment = $scope.cbi.investment
      if investment.amount?
        $scope.cbi.investment.amount = Math.round10(investment.amount * 10000)
      else
        $scope.cbi.investment = null
      $scope.cbi.position_title = null if $scope.cbi.position_title.job_title is null
      TaskSvc.cbiAdd($scope.cbi, cbi_type, language)
      $scope.input_page[cbi_type] = "blank.html"

    return
]

angular.module('app').requires.push 'tasks.task_svc'