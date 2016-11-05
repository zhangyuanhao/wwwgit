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
this.views.institutions ?= {}

views.institutions.index = angular.module 'institutions.list', [
  'api_internal.institution'
  'api.helper'
  'ui.parts'
]

views.institutions.index.factory 'InstitutionList', [
  'Institution'
  'LinkHeader'
  (Institution, LinkHeader) ->
    service         = {}
    service.links   = LinkHeader.links
    service.values  = []
    service.options = {}

    service.reload = (q) ->
      query = if q then q else '*'
      opt = service.options
      service.values = Institution.query
        page        : opt.page
        per_page    : opt.pageSize,
        q           : "(name:#{query})OR(former_name:#{query})"
        sort        : opt.sort.join(','),
        (value, headers) ->
          LinkHeader.updateLinks opt.nextPage, opt.prevPage, headers

    service
]

.controller 'InstitutionsCtrl', [
  '$scope'
  'InstitutionList'
  ($scope, InstitutionList) ->
    $scope.List     = InstitutionList
    $scope.jsRoutes = jsRoutes
    $scope.keyword  = ''

    $scope.$watch 'keyword', (nv) ->
      InstitutionList.reload nv

    return
]

angular.module('app').requires.push 'institutions.list'