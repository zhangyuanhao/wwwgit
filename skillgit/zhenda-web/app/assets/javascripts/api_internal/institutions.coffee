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
# Model Institution
# -------------------------------------------------------- #
angular.module 'api_internal.institution', [ 'ngResource' ]

  .factory 'Institution', [ '$resource', '$http', ($resource, $http) ->
    resource = $resource '/api_internal/institutions/:id', {
      id : '@id'
    }, {
      create :
        method : 'POST'
        params :
          id : ''
    }

    resource.nnew = () -> $http.get '/api_internal/institutions/new'

    return resource
  ]