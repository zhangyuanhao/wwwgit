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
# Model Employee
# -------------------------------------------------------- #
angular.module 'api_internal.employee', [ 'ngResource' ]

  .factory 'Employee', [ '$resource', '$http', ($resource, $http) ->
    resource = $resource '/api_internal/employees/:id/:relations_or_actions/:rid', {
      id                   : '@id'
      relations_or_actions : ''
      rid                  : ''
    }, {
      create :
        method : 'POST'
        params :
          id : ''

      following :
        method : 'GET'
        params :
          relations_or_actions : 'following'
          rid                  : ''

      rehire :
        method : 'POST'
        params :
          relations_or_actions : 'rehire'
          rid                  : ''

      resign :
        method : 'POST'
        params :
          relations_or_actions : 'resign'
          rid                  : ''
    }

    resource.nnew = -> $http.get '/api_internal/employees/nnew'

    resource.performance = (params) ->
      $http(
        method : 'GET'
        url    : "/api_internal/employees/performance"
        params : params
      )

    return resource
  ]