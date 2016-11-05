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
# Model Customer
# -------------------------------------------------------- #
angular.module 'api_internal.customer', [ 'ngResource' ]

  .factory 'Customer', [
    '$resource'
    '$http'
    ($resource, $http) ->
      resource = $resource '/api_internal/customers/:id/:relations/:rid', {
        id        : '@id'
        relations : ''
        rid       : ''
      }, {

        create :
          method : 'POST'
          params :
            id : ''

        hrs :
          method : 'GET'
          params :
            relations : 'hrs'
          isArray : true

        account_executives:
          method : 'GET'
          params :
            relations : 'account_executives'
            rid       : ''
          isArray : true

        addHR :
          method : 'POST'
          params :
            relations : 'hrs'

        delHR :
          method : 'DELETE'
          params :
            relations : 'hrs'

        serviceSetsKeys :
          method : 'GET'
          params :
            relations : 'options_set'
            rid       : 'keys'
          isArray : true

        serviceSet :
          method : 'GET'
          params :
            relations : 'options_set'

        addServiceSet :
          method : 'POST'
          params :
            relations : 'options_set'

        delServiceSet :
          method : 'DELETE'
          params :
            relations : 'options_set'

        invoice :
          method : 'GET'
          params :
            relations : 'invoice'
          isArray : true
      }

      resource.nnew = -> $http.get '/api_internal/customers/new'

      resource.lastContract = (id) ->
        $http.get "/api_internal/customers/#{id}/contracts/last"

      resource.defaultAuthorization = ->
        $http.get "/api_internal/contracts/default_authorization"

      resource.createContract = (id, content) ->
        $http.post(
          "/api_internal/customers/#{id}/contracts"
          content
        )

      resource.reviseContract = (id, cid, contract) ->
        $http.post(
          "/api_internal/customers/#{id}/contracts/#{cid}"
          contract
        )

      return resource
  ]