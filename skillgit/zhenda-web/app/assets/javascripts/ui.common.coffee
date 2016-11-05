#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

#
# Common UI Helpers.
#
angular.module 'ui.common', [ 'ngCookies' ]

#
# The toggle button for minimalizing side bar.
#
.controller 'minimalizaSidebarCtrl', [
  '$scope'
  '$cookies'
  '$timeout'
  ($scope, $cookies, $timeout) ->

    $scope.minimalize = ->
      previous = $cookies.get('mini-navbar') is 'Y'
      minimalized = if previous then 'N' else 'Y'
      # Set cookie
      $cookies.put 'mini-navbar', minimalized, path : '/'
      # Toggle mini-navbar
      $('body').toggleClass 'mini-navbar', minimalized
      if !minimalized or $('body').hasClass('body-small')
        # Hide menu in order to smoothly turn on when maximize menu
        $('.side-menu').hide()
        # For smoothly turn on menu
        $timeout (->
          $('.side-menu').fadeIn 400
        ), 200
      else
        # Remove all inline style from jquery fadeIn function to reset menu state
        $('.side-menu').removeAttr 'style'
      return

    # Set mini-navbar based on cookie
    $('body').toggleClass 'mini-navbar', $cookies.get('mini-navbar') is 'Y'

    return
]

.directive 'minimalizaSidebar',  [
  ->
    {
      restrict: 'A'
      template: """
        <a class="navbar-minimalize minimalize-styl-2 btn btn-primary " href="" ng-click="minimalize()">
          <i class="fa fa-bars"></i>
        </a>"""
      controller: 'minimalizaSidebarCtrl'
    }
]

#
# 空字符串转换为null
#
# 输入栏处请添加empty-to-null属性
#
.directive 'emptyToNull', ->
  restrict : 'A'
  require  : '?ngModel'
  link     : (scope, element, attr, ctrl) ->
    ctrl.$parsers.push((viewValue) ->
      return null if viewValue is ""
      viewValue
    )

#
# datepicker日期格式转换为String
#
# 转换格式为：yyyy-MM-dd
#
.directive 'localdateToString', [ '$filter', ($filter) ->
  restrict : 'A'
  require  : 'ngModel'
  priority : 1
  link     : (scope, element, attr, ctrl) ->
    ctrl.$validators.date = -> true if ctrl and ctrl.$validators.date

    ctrl.$parsers.push((date) ->
      ret = null
      ret = $filter('date')(date, 'yyyy-MM-dd') if date?
      return ret
    )

    ctrl.$formatters.push((value) ->
      if !value then ''
      else if value is '1900-01-01' then ''
      else if angular.isString value then Date.parse value
      else value
    )
  ]
#
# 期间filter
#
# 1. start为空时，返回""
# 2. end为空时，用传进来的参数untilNow替代，未传入参数时默认用"now"替代
#
.filter 'interval', [ 'dateFilter', (dateFilter) ->
  return (input, intervalFormat, dateFormat, untilNow) ->
    if input?
      start = Date.parse input.start if input.start?
      end   = Date.parse input.end if input.end?
      return intervalFormat
        .replace "{0}", dateFilter(start, dateFormat) || ""
        .replace "{1}", dateFilter(end, dateFormat) || untilNow || "now"
    else
      return ""
  ]

#
# 地址filter
#
# 省，市，街道1，街道2的字符串拼接
# 如提供country_dictionary参数，字符串前添加国家名称
#
.filter 'address', [ ->
  return (input, country_dictionary) ->
    input = input || {}

    address001 = (addr, country_name)->
      ret = ""
      if addr.province? and addr.province isnt ""
        ret += country_name + " " if country_name?
        ret += addr.province
        ret += " " + addr.city if addr.city?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address002 = (addr, country_name)->
      ret = ""
      if addr.province? and addr.province isnt ""
        ret += country_name + " " if country_name?
        ret += addr.province
        ret += " " + addr.district if addr.district?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address003 = (addr, country_name)->
      ret = ""
      if addr.city? and addr.city isnt ""
        ret += country_name + " " if country_name?
        ret += addr.city
        ret += " " + addr.district if addr.district?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address004 = (addr, country_name)->
      ret = ""
      if addr.governorate? and addr.governorate isnt ""
        ret += country_name + " " if country_name?
        ret += addr.governorate
        ret += " " + addr.district if addr.district?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address005 = (addr, country_name)->
      ret = ""
      if addr.city? and addr.city isnt ""
        ret += country_name + " " if country_name?
        ret += addr.city
        ret += " " + addr.suburb if addr.suburb?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address006 = (addr, country_name)->
      ret = ""
      if addr.state? and addr.state isnt ""
        ret += country_name + " " if country_name?
        ret += addr.state
        ret += " " + addr.suburb if addr.suburb?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address007 = (addr, country_name)->
      ret = ""
      if addr.state? and addr.state isnt ""
        ret += country_name + " " if country_name?
        ret += addr.state
        ret += " " + addr.city if addr.city?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address008 = (addr, country_name)->
      ret = ""
      if addr.county? and addr.county isnt ""
        ret += country_name + " " if country_name?
        ret += addr.county
        ret += " " + addr.city if addr.city?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address009 = (addr, country_name)->
      ret = ""
      if addr.city? and addr.city isnt ""
        ret += country_name + " " if country_name?
        ret += addr.city
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address010 = (addr, country_name)->
      ret = ""
      if addr.state? and addr.state isnt ""
        ret += country_name + " " if country_name?
        ret += addr.state
        ret += " " + addr.city if addr.city?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address011 = (addr, country_name)->
      ret = ""
      if addr.prefecture? and addr.prefecture isnt ""
        ret += country_name + " " if country_name?
        ret += addr.prefecture
        ret += " " + addr.country_city if addr.country_city?
        ret += " " + addr.further_divisions1 if addr.further_divisions1?
        ret += " " + addr.further_divisions2 if addr.further_divisions2?
      ret

    address012 = (addr, country_name)->
      ret = ""
      if addr.county? and addr.county isnt ""
        ret += country_name + " " if country_name?
        ret += addr.county
        ret += " " + addr.township if addr.township?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address013 = (addr, country_name)->
      ret = ""
      if addr.region? and addr.region isnt ""
        ret += country_name + " " if country_name?
        ret += addr.region
        ret += " " + addr.district if addr.district?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address014 = (addr, country_name)->
      ret = ""
      if addr.region? and addr.region isnt ""
        ret += country_name + " " if country_name?
        ret += addr.region
        ret += " " + addr.city if addr.city?
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    address100 = (addr, country_name)->
      ret = ""
      if addr.city? and addr.city isnt ""
        ret += country_name + " " if country_name?
        ret += addr.city
        ret += " " + addr.street1 if addr.street1?
        ret += " " + addr.street2 if addr.street2?
      ret

    output = ""
    country_name = country_dictionary[input.country] if country_dictionary?

    switch input.country
      when 'CN','ZA','KR','CA','IT','UA','RU','ES','BY' then output = address001(input, country_name)
      when 'TH' then output = address002(input, country_name)
      when 'PH' then output = address003(input, country_name)
      when 'EG' then output = address004(input, country_name)
      when 'NZ' then output = address005(input, country_name)
      when 'AU' then output = address006(input, country_name)
      when 'MY' then output = address007(input, country_name)
      when 'GB','IE' then output = address008(input, country_name)
      when 'CM' then output = address009(input, country_name)
      when 'US' then output = address010(input, country_name)
      when 'JP' then output = address011(input, country_name)
      when 'TW' then output = address012(input, country_name)
      when 'HK' then output = address013(input, country_name)
      when 'MO' then output = address014(input, country_name)
      else output = address100(input, country_name)

    return output
  ]

#
# 职位filter
#
# 部门，职位的字符串拼接
#
.filter 'jobTitle', [ ->
  return (input) ->
    input = input || {}
    output = ""
    if input.job_title?
      output += input.department if input.department?
      output += " " if output?
      output += input.job_title
    return output
  ]

#
# 判断是否超过当前日期filter
#
# 传入的日期+1日后与当前时间比较
#
.filter 'not_expired', [ ->
  return (input) ->
    if input?
      remind_till = Date.parse input
      if remind_till + 24 * 60 * 60 * 1000 > new Date()
        true
      else
        false
    else
      false
  ]

# 姓名filter
#
# 参照当前语言正确表示姓名
#
.filter 'personalName', [ ->
  return (input, language) ->
    first  = input?.first || ''
    last   = input?.last || ''
    middle = input?.middle || []
    switch language
      when "zh" then "#{last}#{first}"
      when "en" then [first].concat(middle).concat(last).join(' ')
      else           [first].concat(middle).concat(last).join(' ')
  ]

#
# 显示万元
#
# 保留一位小数
#
.filter 'ten_thousand', [ ->
  return (input) ->
    if input?
      input/10000
  ]

#
# 显示百分比
#
#
.filter 'percentage', [ ->
  return (input) ->
    if input?
      input + '%'
  ]

#
# upload percentage
#
.filter 'percent', [ ->
  return (value) ->
    p1 = Math.floor((value || 0) * 100)
    p2 = Math.max(0, Math.min(100, p1))
    return """#{p2}%"""
  ]
