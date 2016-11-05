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

views.orders.order_svc = angular.module 'orders.order_svc', [
  'ui.parts'
  'api_internal.order'
  'api_internal.customer'
]

.factory 'OrderSvc', [
  'Alert'
  'Order'
  'Customer'
  (Alert, Order, Customer) ->
    service                  = {}
    service.dictionary       = {}
    # 模版相关
    service.customer_id      = null
    service.preferred_keys   = []

    defaultRange = (total = null)->
      total        : total
      within_years : null
      min_length   : null

    initServiceSet = ->
      service.options_set =
        identity                      : selected : false
        criminal_records              : selected : false
        illegal_organization_records  : selected : false
        court_records                 : selected : false
        financial_irregularities      : selected : false
        conflict_of_business_interest : selected : false
        professional_licenses         : list : [selected : false]
        education                     : list : []
        employment                    : list : []
      service.options_set.professional_licenses.range = defaultRange(1)
      service.options_set.education.range             = defaultRange()
      service.options_set.employment.range            = defaultRange()
      # "目前或最后公司"/"曾就职单位" 两checkbox单独处理
      service.employment_verif = []

    service.candidate_info =
      personal_name :
        first  : null
        last   : null
        middle : []
      phone : null
      email : null
      contact_phone : null
      contact_email : null
      message_for_candidate : null
      message_for_employees : null

    initServiceSet()

    service.loadOrder = ->
      Order.get(
        id : @order_id
        (order) =>
          @candidate_info = order.candidate_info
          @package_name   = order.attributes.PackageName
          @loadServiceOptionsSet(order.options_set)
      )

    service.loadServiceOptionsSet = (o_set) ->
      loadService = (o_set, key) ->
        service.options_set[key] = o_set[key] if o_set[key]?

      # 判断"目前或最后公司"/"曾就职单位"是否勾选
      loadEmploymentVerify = (idx) ->
        employ_list = service.options_set.employment.list
        service.employment_verif[idx] = employ_list[idx]?

      loadService(o_set, 'identity')
      loadService(o_set, 'education')
      loadService(o_set, 'employment')
      loadService(o_set, 'criminal_records')
      loadService(o_set, 'illegal_organization_records')
      loadService(o_set, 'court_records')
      loadService(o_set, 'financial_irregularities')
      loadService(o_set, 'conflict_of_business_interest')
      loadService(o_set, 'professional_licenses')
      loadEmploymentVerify(0)
      loadEmploymentVerify(1)
      return

    service.loadPreferredKeys = ->
      Customer.serviceSetsKeys(
        id : @customer_id
        (keys) => @preferred_keys = keys
      )

    # 取消: 与身份绑定的模块同时取消勾选
    service.toggleIdentity = ->
      if !@options_set.identity.selected
        @options_set.criminal_records.selected              = false
        @options_set.illegal_organization_records.selected  = false
        @options_set.court_records.selected                 = false
        @options_set.financial_irregularities.selected      = false
        @options_set.conflict_of_business_interest.selected = false

    # 取消: 清空education_list内相应内容
    service.toggleEducation = (idx) ->
      edu_list = @options_set.education.list
      if edu_list[idx].education_details.selected
        edu_list[idx].degree = selected : false
      else
        edu_list.splice(idx, edu_list.length - idx)

    # 选中: 向employment_list追加initInterview; 取消: 清空employment_list内相应内容
    service.toggleEmployment = (idx) ->
      employ_list = @options_set.employment.list
      if @employment_verif[idx]
        employ_list[idx] = initInterviews(idx)
      else
        @employment_verif[1] = false
        employ_list.splice(idx, employ_list.length - idx)

    initInterviews = (idx) ->
      interviews :
        PersonnelOfficer :
          employment_details : selected : true
          work_performance   : selected : false
        Supervisor :
          employment_details : selected : true
          work_performance   : selected : true
        Additional1 :
          employment_details : selected : true
          work_performance   : selected : true

    # 选中: 同时勾选employment_verif; 取消: 清空interviews内相应内容(interviews为空时，进一步清空employment_list内相应内容)
    service.toggleInterview = (idx, name) ->
      interviews = @options_set.employment.list[idx].interviews
      interviews[name].employment_details ?= selected : false
      interviews[name].work_performance   ?= selected : false
      if interviews[name].employment_details.selected or interviews[name].work_performance.selected
        @employment_verif[idx] = true
      else
        delete interviews[name]
        if _.isEmpty interviews
          @employment_verif[idx] = false
          @employment_verif[1]   = false
          @toggleEmployment(idx)

    service.orderJsonCheck = ->
      employmentDetailsCheck = (employment, reference)->
        true if employment.interviews[reference]? and employment.interviews[reference].employment_details.selected

      if @employment_verif[0] and not @options_set.employment.range.total?
        return "msg.need_employment_total"

      for employ in @options_set.employment.list
        detail_set = false
        detail_set = true if employmentDetailsCheck(employ, "PersonnelOfficer")
        detail_set = true if employmentDetailsCheck(employ, "Supervisor")
        detail_set = true if employmentDetailsCheck(employ, "Additional1")
        detail_set = true if employmentDetailsCheck(employ, "Additional2")
        if !detail_set
          return "msg.need_employment_detail"
      "OK"

    service.prepareOrderJson = ->
      candidate_info : @candidate_info
      package_name   : @package_name
      options_set    : @prepareServiceSetJson()

    service.prepareServiceSetJson = ->
      # 清空多余部分json
      prepareService = (options_set, key, fn) ->
        delete options_set[key] if fn(options_set[key])

      s_set = angular.copy(@options_set)
      s_set.education.range.total = s_set.education.list.length
      prepareService(s_set, 'identity',                      (p) -> !p.selected)
      prepareService(s_set, 'education',                     (p) -> p.list.length is 0)
      prepareService(s_set, 'employment',                    (p) -> p.list.length is 0 and p.range.total is null and p.range.within_years is null)
      prepareService(s_set, 'criminal_records',              (p) -> !p.selected)
      prepareService(s_set, 'illegal_organization_records',  (p) -> !p.selected)
      prepareService(s_set, 'court_records',                 (p) -> !p.selected)
      prepareService(s_set, 'financial_irregularities',      (p) -> !p.selected)
      prepareService(s_set, 'conflict_of_business_interest', (p) -> !p.selected)
      prepareService(s_set, 'professional_licenses',         (p) -> !p.list[0].selected)
      s_set

    service.showPreferredServiceSet = ->
      initServiceSet()
      if @package_name?
        Customer.serviceSet(
          id  : @customer_id
          rid : @package_name
          (resp) => @loadServiceOptionsSet(resp)
          (error) => @loadPreferredKeys()
        )

    service
]

angular.module('app').requires.push 'orders.order_svc'