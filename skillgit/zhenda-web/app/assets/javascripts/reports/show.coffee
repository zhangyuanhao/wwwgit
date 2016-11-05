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
this.views.reports ?= {}

views.reports.show = angular.module 'reports.show', [
]

views.reports.show

.factory 'ShowSvc', [
 ->
    service            = {}
    service.dictionary = {}

    service
]

.controller 'ShowCtrl', [
  '$scope'
  '$animate'
  'ShowSvc'
  ($scope, $animate, ShowSvc) ->
    $scope.ShowSvc               = ShowSvc
    $scope.show_type             = ShowSvc.dictionary['only_risk']
    $scope.show_all              = true
    $scope.report_info           = is_collapsed : false

    init = ->
      is_collapsed : true
      pre_collapsed : true
      auto_expansion : true
      risk : 'false'

    $scope.identity_info_check           = init()
    $scope.criminal_records              = init()
    $scope.court_records                 = init()
    $scope.financial_irregularities      = init()
    $scope.conflict_of_business_interest = init()
    $scope.illegal_organization_records  = init()
    $scope.professional_licenses         = (init() for i in [0..10])
    $scope.education_info_checks         = (init() for i in [0..10])
    $scope.degree_info_checks            = (init() for i in [0..10])
    $scope.PersonnelOfficer              = (init() for i in [0..30])
    $scope.PersonnelOfficer_Copy         = (init() for i in [0..30])
    $scope.Supervisor                    = (init() for i in [0..30])
    $scope.Supervisor_Copy               = (init() for i in [0..30])
    $scope.Additional1                   = (init() for i in [0..30])
    $scope.Additional1_Copy              = (init() for i in [0..30])
    $scope.Additional2                   = (init() for i in [0..30])
    $scope.Additional2_Copy              = (init() for i in [0..30])

    $scope.switchShow = ->
      # $scope.setCollapsedFlag(!$scope.show_all)
      $scope.show_all = !$scope.show_all
      $scope.show_type =
        switch $scope.show_all
          when true
            fixCollapsed($scope.identity_info_check)
            fixCollapsed($scope.criminal_records)
            fixCollapsed($scope.court_records)
            fixCollapsed($scope.financial_irregularities)
            fixCollapsed($scope.conflict_of_business_interest)
            fixCollapsed($scope.illegal_organization_records)
            _.map $scope.professional_licenses, fixCollapsed
            _.map $scope.education_info_checks, fixCollapsed
            _.map $scope.degree_info_checks, fixCollapsed
            _.map $scope.PersonnelOfficer, fixCollapsed
            _.map $scope.PersonnelOfficer_Copy, fixCollapsed
            _.map $scope.Supervisor, fixCollapsed
            _.map $scope.Supervisor_Copy, fixCollapsed
            _.map $scope.Additional1, fixCollapsed
            _.map $scope.Additional1_Copy, fixCollapsed
            _.map $scope.Additional2, fixCollapsed
            _.map $scope.Additional2_Copy, fixCollapsed
            ShowSvc.dictionary['only_risk']
          when false then ShowSvc.dictionary['all']

    $scope.isCollapsed = (component, risk) ->
      component.risk = risk
      if (!$scope.show_all and (risk is 'true') and component.auto_expansion)
        component.auto_expansion = false
        component.pre_collapsed = component.is_collapsed
        component.is_collapsed = false

      component.is_collapsed

    fixCollapsed = (component) ->
      if !component.auto_expansion
        component.auto_expansion = true
        component.is_collapsed = component.pre_collapsed

    return
]

angular.module('app').requires.push 'reports.show'