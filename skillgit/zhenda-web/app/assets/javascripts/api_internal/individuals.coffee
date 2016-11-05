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
# Model Individual
# -------------------------------------------------------- #
angular.module 'api_internal.individual', [ 'ngResource' ]

  .factory 'Individual', [ '$resource', '$http', ($resource, $http) ->
    resource = $resource '/api_internal/individuals/:id/:relations', {
      id        : '@id'
      relations : ''
    }, {
      create :
        method : 'POST'
        params :
          id : ''

      residentIdRecords :
        method  : 'GET'
        params  :
          relations : 'resident_id_records'
        isArray : true
    }

    resource.residentIdRecordsOf = (ids) ->
      $http.get(
        '/api_internal/individuals/resident_id_records'
        params :
          ids : ids.join ','
      )

    resource.verify = (id, icn) ->
      $http.post(
        "/api_internal/individuals/#{id}/verify"
        undefined #不需要body
        params :
          icn : icn
      )

    return resource
  ]