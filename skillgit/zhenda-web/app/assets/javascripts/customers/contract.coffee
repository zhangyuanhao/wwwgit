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
this.views.customers ?= {}

views.customers.contract = angular.module 'customers.contract', [
  'ui.parts'
  'ui.router'
  'api_internal.customer'
  'api_internal.services_definitions'
]

.factory 'ContractSvc', [
  'Alert'
  'Customer'
  'ServicesDefinitions'
  '$filter'
  (Alert, Customer, ServicesDefinitions, $filter) ->
    service = {}
    service.contract = {}
    service.value    = {}
    service.value.identity = {}
    temp_education =
      edu:{}
      degree:{}
    service.value.education    = []
    service.value.education[0] = angular.copy(temp_education)
    service.value.education[1] = angular.copy(temp_education)
    service.value.prl =
      fields          : {}
      extra_gathering : {}
    service.value.cri = {}
    service.value.ill = {}
    service.value.cou = {}
    service.value.fin = {}
    service.value.cbi = {}
    temp_refe =
      PersonnelOfficer:{}
      Supervisor:{}
      Additional1:{}
      Additional2:{}
    service.value.employment    = []
    service.value.employment[0] = angular.copy(temp_refe)
    service.value.employment[1] = angular.copy(temp_refe)

    newDatepicker = ->
      date_options :
        minDate : new Date
      opened : false
      open   : -> this.opened = true

    loadItem = (item, opinion = false)->
      ret_value = {}
      clearValues(ret_value, opinion)
      ret_value.datepicker  = newDatepicker()
      if item?
        ret_value.select      = true
        ret_value.remind_till = item.remind_till
        for value in _.values item.levels
          switch value
            when 'A'   then ret_value.level_A     = true
            when 'A10' then ret_value.level_A10   = true
            when 'A20' then ret_value.level_A20   = true
            when 'B'   then ret_value.level_B     = true
            when 'C'   then ret_value.level_C     = true
            when 'D'   then ret_value.level_D     = true
            when 'Na'  then ret_value.level_Na    = true
        if item.opinions?
          for opinion in _.values item.opinions
            switch opinion
              when 'opinion.yes'     then ret_value.opinion_yes     = true
              when 'opinion.no'      then ret_value.opinion_no      = true
              when 'opinion.unknown' then ret_value.opinion_unknown = true
        _.mapObject item.levels_desc, (val, key) ->
          ret_value["desc_" + key] = val
      ret_value

    loadEducation = (data, idx)->
      loadFields = (data, idx, key)->
        item = data.list[idx].education_details.fields[key]
        service.value.education[idx].edu[key] = loadItem(item)

      loadExtraGathering = (data, idx, key)->
        item = data.list[idx].education_details.extra_gathering.indexOf(key)
        service.value.education[idx].extra_gathering = {} if service.value.education[idx].extra_gathering is undefined
        service.value.education[idx].extra_gathering[key] = false
        service.value.education[idx].extra_gathering[key] = true if item > -1

      loadFields(data, idx, "institution")
      loadFields(data, idx, "interval")
      loadFields(data, idx, "address")
      loadFields(data, idx, "major")
      loadFields(data, idx, "education_level")
      loadFields(data, idx, "mode_of_study")

      loadExtraGathering(data, idx, "institution")
      loadExtraGathering(data, idx, "interval")
      loadExtraGathering(data, idx, "address")
      loadExtraGathering(data, idx, "major")
      loadExtraGathering(data, idx, "education_level")
      loadExtraGathering(data, idx, "mode_of_study")
      loadExtraGathering(data, idx, "degree_awarded")
      loadExtraGathering(data, idx, "diploma_images")
      loadExtraGathering(data, idx, "diploma_number")

    loadDegree = (data, idx)->
      loadFields = (data, idx, key)->
        item = data.list[idx].degree.fields[key]
        service.value.education[idx].degree[key] = loadItem(item)

      loadExtraGathering = (data, idx, key)->
        item = data.list[idx].degree.extra_gathering.indexOf(key)
        service.value.education[idx].extra_gathering[key] = false
        service.value.education[idx].extra_gathering[key] = true if item > -1

      loadFields(data, idx, "institution")
      loadFields(data, idx, "major")
      loadFields(data, idx, "date_of_award")
      loadFields(data, idx, "degree_type")

      loadExtraGathering(data, idx, "date_of_award")
      loadExtraGathering(data, idx, "degree_type")
      loadExtraGathering(data, idx, "degree_images")

    loadProfessionalLicense = (data)->
      loadFields = (data, key)->
        item = data.fields[key]
        service.value.prl.fields[key] = loadItem(item)

      loadExtraGathering = (data, key)->
        item = data.extra_gathering.indexOf(key)
        service.value.prl.extra_gathering[key] = false
        service.value.prl.extra_gathering[key] = true if item > -1

      loadFields(data, "issue_date")
      loadFields(data, "license_type")
      loadFields(data, "location")
      loadFields(data, "organization")

      loadExtraGathering(data, "issue_date")
      loadExtraGathering(data, "license_type")
      loadExtraGathering(data, "location")
      loadExtraGathering(data, "organization")
      loadExtraGathering(data, "expire_date")
      loadExtraGathering(data, "license_number")
      loadExtraGathering(data, "contact_info")
      loadExtraGathering(data, "images")

    loadFinancialIrregularity = (data)->
      loadFields = (data, key)->
        item = data.extra_checks[key]
        service.value.fin[key] = loadItem(item)

      loadFields(data, "csrc_ap")
      loadFields(data, "csrc_smb")
      loadFields(data, "circ_ap")

    loadConflictOfBusinessInterest = (data)->
      loadFields = (data, key)->
        item = data.extra_checks[key]
        service.value.cbi[key] = loadItem(item)

      loadFields(data, "legal_representative")
      loadFields(data, "shareholder")
      loadFields(data, "corporate_executive")

    loadEmployment = (data, idx)->
      loadReference = (data, idx, reference)->
        loadReferenceChecks = (data, idx, refe_type, key)->
          item = data.list[idx].interviews[reference].reference.extra_checks[key]
          service.value.employment[idx][reference][key] = loadItem(item)

        loadFields = (data, idx, refe_type, key)->
          item = data.list[idx].interviews[reference].employment_details.fields[key]
          service.value.employment[idx][reference][key] = loadItem(item)

        loadExtraChecks = (data, idx, refe_type, key)->
          item = data.list[idx].interviews[reference].employment_details.extra_checks[key]
          service.value.employment[idx][reference][key] = loadItem(item)

        loadExtraGathering = (data, idx, refe_type, key)->
          item = data.list[idx].interviews[reference].employment_details.extra_gathering.indexOf(key)
          service.value.employment[idx][reference].extra_gathering = {} if service.value.employment[idx][reference].extra_gathering is undefined
          service.value.employment[idx][reference].extra_gathering[key] = false
          service.value.employment[idx][reference].extra_gathering[key] = true if item > -1

        loadWorkPerformance = (data, idx, refe_type, key)->
          item = data.list[idx].interviews[reference].work_performance.extra_checks[key]
          service.value.employment[idx][reference].work_performance = {} if service.value.employment[idx][reference].work_performance is undefined
          service.value.employment[idx][reference].work_performance[key] = false
          if item?
            service.value.employment[idx][reference].work_performance[key]= true
            item.opinions = service.opinions[key] if key isnt "rating"

        loadReferenceChecks(data, idx, reference, "authenticity")

        loadFields(data, idx, reference, "employer_name")
        loadFields(data, idx, reference, "interval_optional_end")
        loadFields(data, idx, reference, "interval")
        loadFields(data, idx, reference, "address")
        loadFields(data, idx, reference, "position_title")
        loadFields(data, idx, reference, "hire_type")
        loadFields(data, idx, reference, "earnings")
        loadFields(data, idx, reference, "major_responsibility")
        loadFields(data, idx, reference, "reason_for_leaving")
        loadFields(data, idx, reference, "handed_over")

        loadExtraChecks(data, idx, reference, "supervisor_position_title")
        loadExtraChecks(data, idx, reference, "labor_dispute")
        loadExtraChecks(data, idx, reference, "misconduct")
        loadExtraChecks(data, idx, reference, "nonsolicitation_agreement")
        loadExtraChecks(data, idx, reference, "training_agreement")
        loadExtraChecks(data, idx, reference, "willing_to_rehire")

        loadWorkPerformance(data, idx, reference, "strengths")
        loadWorkPerformance(data, idx, reference, "weaknesses")
        loadWorkPerformance(data, idx, reference, "future_thinking")
        loadWorkPerformance(data, idx, reference, "leadership_and_management")
        loadWorkPerformance(data, idx, reference, "professional_knowledge")
        loadWorkPerformance(data, idx, reference, "working_attitude")
        loadWorkPerformance(data, idx, reference, "stress_management")
        loadWorkPerformance(data, idx, reference, "interpersonal_relationships")
        loadWorkPerformance(data, idx, reference, "rating")

        loadExtraGathering(data, idx, reference, "employee_number")
        loadExtraGathering(data, idx, reference, "performance_description")
        loadExtraGathering(data, idx, reference, "still_employed")
        loadExtraGathering(data, idx, reference, "no_check_until")
        loadExtraGathering(data, idx, reference, "supervisor_position_title")
        loadExtraGathering(data, idx, reference, "employer_name")
        loadExtraGathering(data, idx, reference, "address")
        loadExtraGathering(data, idx, reference, "telephone")
        loadExtraGathering(data, idx, reference, "interval_optional_end")
        loadExtraGathering(data, idx, reference, "interval")
        loadExtraGathering(data, idx, reference, "position_title")
        loadExtraGathering(data, idx, reference, "hire_type")
        loadExtraGathering(data, idx, reference, "earnings")
        loadExtraGathering(data, idx, reference, "major_responsibility")
        loadExtraGathering(data, idx, reference, "reason_for_leaving")
        loadExtraGathering(data, idx, reference, "handed_over")

      loadReference(data, idx, "PersonnelOfficer",true)
      loadReference(data, idx, "Supervisor",true)
      loadReference(data, idx, "Additional1",true)
      loadReference(data, idx, "Additional2",true)

    loadLanguage = (langs)->
      loadLang = (language, langs) ->
        return true if language is langs.lang
        for l in langs.other_langs
          return true if language is l
        false
      service.lang = {}
      service.lang.zh = loadLang("zh", langs)
      service.lang.en = loadLang("en", langs)
      service.lang.ja = loadLang("ja", langs)
      service.lang.default = langs.lang

    loadAuthorization = (data)->
      service.need_authorization = data?


    loadContract = (customer_id)->
      Customer.lastContract(customer_id).then(
        (last) ->
          service.contract = last.data
          contract = last.data.content
          basic_info = contract.identity.fields.basic_info
          service.value.identity.basic_info = loadItem(basic_info)
          cri = contract.criminal_records.extra_checks.records
          service.value.cri.records = loadItem(cri)
          if !contract.illegal_organization_records
            contract.illegal_organization_records =
              extra_gathering : ['basic_info']
              fields : {}
              extra_checks :
                records :
                  default     : null
                  levels      : ['D', 'C', 'A']
                  levels_desc : {}
                  remind_till : null
          ill = contract.illegal_organization_records.extra_checks.records
          service.value.ill.records = loadItem(ill)
          cou = contract.court_records.extra_checks.records
          service.value.cou.records = loadItem(cou)
          loadProfessionalLicense(contract.professional_licenses.list[0])
          loadFinancialIrregularity(contract.financial_irregularities)
          loadConflictOfBusinessInterest(contract.conflict_of_business_interest)
          loadEducation(contract.education, 0)
          loadEducation(contract.education, 1)
          loadDegree(contract.education, 0)
          loadDegree(contract.education, 1)
          loadEmployment(contract.employment, 0)
          loadEmployment(contract.employment, 1)
          loadLanguage(contract.additional_terms)
          loadAuthorization(contract.authorization)
        (error) ->
          Alert.danger error.data.message
      )

    service.load = (customer_id)->
      ServicesDefinitions.workPerformanceOpinions(
        (opinions) ->
          service.opinions = opinions
          loadContract(customer_id)
          loadDefaultAuthorization()
        (error) ->
          Alert.danger error.data.message
      )

    loadDefaultAuthorization = ->
      Customer.defaultAuthorization().then(
        (authorization) ->
          service.defaultAuthorization = authorization.data
        (error) ->
          Alert.danger error.data.message
      )

    initFields = (opinion = false)->
      default     : null
      remind_till : null
      levels_desc : {}

    clearValues = (value, opinion = false)->
      value.select      = false
      value.level_A     = false
      value.level_A10   = false
      value.level_A20   = false
      value.level_B     = false
      value.level_C     = false
      value.level_D     = false
      value.level_Na    = false
      value.desc_A      = ""
      value.desc_A10    = ""
      value.desc_A20    = ""
      value.desc_B      = ""
      value.desc_C      = ""
      value.desc_D      = ""
      value.desc_Na     = ""
      value.remind_till = null
      if opinion
        value.opinion_yes     = false
        value.opinion_no      = false
        value.opinion_unknown = false

    levelSelect = (key, level_type, value, contract)->
      level_select = value["level_" + level_type]
      if !level_select
        delete contract[key].levels_desc[level_type] if contract[key].levels_desc[level_type]?
        value["desc_" + level_type] = ""
      level_select

    saveItem = (key, type, value, contract, desc_type, opinion = false)->
      if type == 1
        if value.select
          contract[key] = initFields()
          contract[key].levels = ["D","C","A"]
          value.level_A = true
          value.level_C = true
          value.level_D = true
          if opinion
            contract[key].opinions = ["opinion.yes", "opinion.no", "opinion.unknown"]
            value.opinion_yes     = true
            value.opinion_no      = true
            value.opinion_unknown = true
        else
          clearValues(value,opinion)
          delete contract[key]
      else if type == 2
        levels = []
        levels.push "D"   if levelSelect(key, "D", value, contract)
        levels.push "C"   if levelSelect(key, "C", value, contract)
        levels.push "B"   if levelSelect(key, "B", value, contract)
        levels.push "A"   if levelSelect(key, "A", value, contract)
        levels.push "Na"  if levelSelect(key, "Na", value, contract)
        levels.push "A20" if levelSelect(key, "A20", value, contract)
        levels.push "A10" if levelSelect(key, "A10", value, contract)
        if _.isEmpty levels
          clearValues(value,opinion)
          delete contract[key]
        else
          contract[key].levels = levels
      else if type == 3
        desc = value["desc_" + desc_type]
        if desc? and desc isnt ""
          contract[key].levels_desc[desc_type] = desc
        else
          delete contract[key].levels_desc[desc_type] if contract[key].levels_desc[desc_type]?
      else if type == 4
        contract[key].remind_till = value.remind_till

    service.saveIdentity = (key, type, desc_type)->
      value    = @value.identity[key]
      contract = @contract.content.identity.fields
      saveItem(key, type, value, contract, desc_type)

    service.saveEducation = (key, type, idx, desc_type)->
      value    = @value.education[idx].edu[key]
      contract = @contract.content.education.list[idx].education_details.fields
      saveItem(key, type, value, contract, desc_type)

    service.saveDegree = (key, type, idx, desc_type)->
      value    = @value.education[idx].degree[key]
      contract = @contract.content.education.list[idx].degree.fields
      saveItem(key, type, value, contract, desc_type)

    service.savePrl = (key, type, desc_type)->
      value    = @value.prl.fields[key]
      contract = @contract.content.professional_licenses.list[0].fields
      saveItem(key, type, value, contract, desc_type)

    service.saveCri = (key, type, desc_type)->
      value    = @value.cri[key]
      contract = @contract.content.criminal_records.extra_checks
      saveItem(key, type, value, contract, desc_type)

    service.saveIll = (key, type, desc_type)->
      value    = @value.ill[key]
      contract = @contract.content.illegal_organization_records.extra_checks
      saveItem(key, type, value, contract, desc_type)

    service.saveCou = (key, type, desc_type)->
      value    = @value.cou[key]
      contract = @contract.content.court_records.extra_checks
      saveItem(key, type, value, contract, desc_type)

    service.saveFin = (key, type, desc_type)->
      value    = @value.fin[key]
      contract = @contract.content.financial_irregularities.extra_checks
      saveItem(key, type, value, contract, desc_type)

    service.saveCbi = (key, type, desc_type)->
      value    = @value.cbi[key]
      contract = @contract.content.conflict_of_business_interest.extra_checks
      saveItem(key, type, value, contract, desc_type)

    service.saveReferenceCheck = (key, type, idx, reference, desc_type)->
      value    = @value.employment[idx][reference][key]
      contract = @contract.content.employment.list[idx].interviews[reference].reference.extra_checks
      saveItem(key, type, value, contract, desc_type)

    service.saveEmployment = (key, type, idx, reference, desc_type)->
      value    = @value.employment[idx][reference][key]
      contract = @contract.content.employment.list[idx].interviews[reference].employment_details.fields
      saveItem(key, type, value, contract, desc_type)

    service.saveSupervisorTitle = (type, idx, reference, desc_type)->
      value    = @value.employment[idx][reference].supervisor_position_title
      contract = @contract.content.employment.list[idx].interviews[reference].employment_details.extra_checks
      saveItem('supervisor_position_title', type, value, contract, desc_type)

    service.saveDetermine = (key, type, idx, reference, desc_type)->
      value    = @value.employment[idx][reference][key]
      contract = @contract.content.employment.list[idx].interviews[reference].employment_details.extra_checks
      saveItem(key, type, value, contract, desc_type, true)

    service.saveOpinions = (key, idx, reference)->
      value    = @value.employment[idx][reference][key]
      contract = @contract.content.employment.list[idx].interviews[reference].employment_details.extra_checks
      opinions = []
      opinions.push "opinion.yes"     if value.opinion_yes
      opinions.push "opinion.no"      if value.opinion_no
      opinions.push "opinion.unknown" if value.opinion_unknown
      if _.isEmpty opinions
        clearValues(value, true)
        delete contract[key]
      else
        contract[key].opinions = opinions

    service.saveWorkPerformance = (key, idx, reference)->
      value    = @value.employment[idx][reference].work_performance[key]
      contract = @contract.content.employment.list[idx].interviews[reference].work_performance.extra_checks
      if value
        if key == "rating"
          contract[key] = default : 1
        else
          contract[key] = opinions : service.opinions[key]
      else
        delete contract[key]

    saveExtraGathering = (key, value, extra_gatherings)->
      if value
        extra_gatherings.push key if extra_gatherings.indexOf(key) is -1
      else
        select = -1
        for item, i in extra_gatherings
          select = i if item is key
        extra_gatherings.splice(select,1) if select isnt -1

    service.saveEmploymentExtraGathering = (key, idx, reference)->
      value    = @value.employment[idx][reference].extra_gathering[key]
      extra_gatherings = @contract.content.employment.list[idx].interviews[reference].employment_details.extra_gathering
      saveExtraGathering(key, value, extra_gatherings)

    service.saveEducationExtraGathering = (key, idx, edu_type)->
      value    = @value.education[idx].extra_gathering[key]
      extra_gatherings = @contract.content.education.list[idx][edu_type].extra_gathering
      saveExtraGathering(key, value, extra_gatherings)

    service.savePLExtraGathering = (key)->
      value    = @value.prl.extra_gathering[key]
      extra_gatherings = @contract.content.professional_licenses.list[0].extra_gathering
      saveExtraGathering(key, value, extra_gatherings)

    service.saveLanguages = (key)->
      language = @contract.content.additional_terms
      if key is "default"
        language.lang = service.lang.default
        language.other_langs = []
        language.other_langs.push "zh" if service.lang.zh is true and service.lang.default isnt "zh"
        language.other_langs.push "en" if service.lang.en is true and service.lang.default isnt "en"
        language.other_langs.push "ja" if service.lang.ja is true and service.lang.default isnt "ja"
      else
        if key is service.lang.default and service.lang[key] is false
          Alert.danger service.dictionary['msg.remove_default_lang']
          service.lang[key] = true
          return
        if service.lang[key] is true
          if !language.other_langs[key]
            language.other_langs.push key
        else
          for l, idx in language.other_langs
            language.other_langs.splice(idx,1) if l is key

    service.saveAuthorization = ->
      if @need_authorization
        @contract.content.authorization = angular.copy @defaultAuthorization
      else
        delete @contract.content.authorization if @contract.content.authorization?

    service.save = (customer_id)->
      if service.contract.id?
        Customer.reviseContract(
          customer_id, @contract.id, @contract
        ).then(
          (resp) -> Alert.success service.dictionary['msg.contract_saved']
          (error) -> Alert.danger error.data.message
        )
      else
        Customer.createContract(
          customer_id, service.contract.content
        ).then(
          (resp) ->
            service.contract = resp.data
            Alert.success service.dictionary['msg.contract_saved']
          (error) -> Alert.danger error.data.message
        )

    service
]

.controller 'ContractCtrl', [
  '$scope'
  '$window'
  '$state'
  'ContractSvc'
  ($scope, $window, $state, ContractSvc) ->
    $scope.ContractSvc = ContractSvc
    $scope.const_false = false
    $scope.scrollClass = 'affix-static'

    $scope.routeTabs = (key) ->
      $scope.selected_tab = key
      $state.go(key)

    scrollHandler = ->
      if $window.scrollY > 100
        if $scope.scrollClass is 'affix-static'
          $scope.scrollClass = 'affix-fixed'
          $scope.$apply()
      else
        if $scope.scrollClass is 'affix-fixed'
          $scope.scrollClass =  'affix-static'
          $scope.$apply()

    angular.element($window).on('scroll', scrollHandler)

    return
]

angular.module('app').requires.push 'customers.contract'