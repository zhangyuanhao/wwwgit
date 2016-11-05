#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

# -------------------------------------------------------- #
# Model Order
# -------------------------------------------------------- #
angular.module 'api_internal.order', [ 'ngResource' ]

  .factory 'Order', [ '$resource','$http', ($resource, $http) ->
    url = '/api_internal/orders'

    resource = $resource "#{url}/:id",{
      id : '@id'
    },{
      create :
        method : 'POST'
        params :
          id : ''
    }

    resource.search = (params) ->
      $http.get("#{url}/search" , params : params)

    resource.index = (params) ->
      $http.get("#{url}/index" , params : params)

    resource.tracks = (id) ->
      $http.get "#{url}/#{id}/tracks"

    resource.counts = (filters) ->
      $http.get(
        "#{url}/counts"
        params :
          filters : filters.join ','
      )

    resource.monthlyOrdersCounts = (params) ->
      $http.get("#{url}/monthly_orders_counts" , params : params)

    resource.yearlyOnTimeRatio = (params) ->
      $http.get("#{url}/yearly_on_time_ratio" , params : params)

    resource.riskReportsRadio = (params) ->
      $http.get("#{url}/risk_reports_radio" , params : params)

    resource.yearlyLightsRatio = (params) ->
      $http.get("#{url}/yearly_lights_ratio" , params : params)

    resource.yearlyModulesRatio = (params) ->
      $http.get("#{url}/yearly_modules_ratio" , params : params)

    return resource
  ]