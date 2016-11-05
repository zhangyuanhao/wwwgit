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
this.views.individuals ?= {}

views.individuals.index = angular.module 'individuals.list', [
  'api_internal.individual'
  'api.helper'
  'ui.parts'
]

views.individuals.index

.factory 'IndividualList', [
  'Individual'
  'LinkHeader'
  (Individual, LinkHeader) ->
    service         = {}
    service.links   = LinkHeader.links
    service.values  = []
    service.options = {}

    service.reload = (q) ->
      opt = service.options
      service.values = Individual.query
        page        : opt.page
        per_page    : opt.pageSize
        q           : if q then "personal_name.full_name:#{q}" else "*"
        sort        : opt.sort.join(','),
        (value, headers) ->
          LinkHeader.updateLinks opt.nextPage, opt.prevPage, headers

    service
]

.controller 'IndividualsCtrl', [
  '$scope'
  'IndividualList'
  ($scope, IndividualList) ->
    $scope.IndividualList = IndividualList
    $scope.jsRoutes       = jsRoutes
    $scope.keyword        = ''

    $scope.$watch 'keyword', (nv) ->
      IndividualList.reload nv

    return
]

angular.module('app').requires.push 'individuals.list'