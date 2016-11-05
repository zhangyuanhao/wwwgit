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
this.views.business_entities ?= {}

views.business_entities.index = angular.module 'businessEntities.list', [
  'ui.bootstrap'
  'ui.parts'
  'api_internal.business_entity'
  'api.helper'
]

.factory 'BusinessEntityList', [
  'BusinessEntity'
  'LinkHeader'
  (BusinessEntity, LinkHeader) ->
    service            = {}
    service.links      = LinkHeader.links
    service.values     = []
    service.options    = {}
    service.dictionary = {}

    service.reload = (q) ->
      opt            = service.options
      service.values = BusinessEntity.query
        page     : opt.page
        per_page : opt.pageSize
        q        : if q then "(name:#{q})OR(phone:#{q}*)" else "(name:*)OR(phone:*)"
        sort     : opt.sort.join(','),
        (values, headers) ->
          LinkHeader.updateLinks opt.nextPage, opt.prevPage, headers

    service
]

.controller 'BusinessEntitiesCtrl', [
  '$scope'
  'BusinessEntityList'
  ($scope, BusinessEntityList) ->
    $scope.jsRoutes   = jsRoutes
    $scope.List       = BusinessEntityList
    $scope.keyword    = ''

    $scope.$watch 'keyword', (nv) ->
      BusinessEntityList.reload nv

    return
]


angular.module('app').requires.push 'businessEntities.list'